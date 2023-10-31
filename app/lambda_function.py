import json
import os

import boto3

cognito = boto3.client('cognito-idp')

cognito_client_id = os.getenv('COGNITO_CLIENT_ID')
cognito_user_pool_id = os.getenv('COGNITO_USER_POOL_ID')


def handler(event, context):
    try:

        auth_response = sign_up(event)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Usuário autenticado com sucesso',
                'response': auth_response
            })
        }

    except cognito.exceptions.NotAuthorizedException:
        return {
            'statusCode': 401,
            'body': json.dumps({'message': 'Usuário não autorizado'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Erro desconhecido: ' + str(e)})
        }


def sign_up(event):
    try:
        sign_up_response = cognito.sign_up(
            ClientId=cognito_client_id,
            Username=event['cpf'],
            Password=event['cpf']
        )

        if sign_up_response['UserConfirmed']:
            return initiate_auth(event)
        else:
            return None

    except cognito.exceptions.UsernameExistsException as e:
        print("Usuário com o mesmo nome de usuário já existe.", e)
        return initiate_auth(event)
    except Exception as e:
        print("Erro ao criar usuário:", e)
    return None


def initiate_auth(event):
    try:
        return cognito.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': event['cpf'],
                'PASSWORD': event['cpf']
            },
            ClientId=cognito_client_id
        )
    except cognito.exceptions.NotAuthorizedException as e:
        print("Usuário não autorizado.", e)
        return None
    except Exception as e:
        print("Erro ao fazer login:", e)
        return None
