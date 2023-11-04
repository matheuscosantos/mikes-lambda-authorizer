import json
import os

import boto3

cognito = boto3.client('cognito-idp')

cognito_client_id = os.getenv('COGNITO_CLIENT_ID')
cognito_user_pool_id = os.getenv('COGNITO_USER_POOL_ID')
cognito_admin_username = os.getenv('COGNITO_ADMIN_USERNAME')


def handler(event, context):
    try:

        username = json.loads(event['body'])['cpf']

        if username is None or username == '':
            username = cognito_admin_username

        auth_response = sign_up(username)

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


def sign_up(username):
    try:
        sign_up_response = cognito.sign_up(
            ClientId=cognito_client_id,
            Username=username,
            Password=username
        )

        if sign_up_response['UserConfirmed']:
            return initiate_auth(username)
        else:
            return None

    except cognito.exceptions.UsernameExistsException as e:
        print("Usuário com o mesmo nome de usuário já existe.", e)
        return initiate_auth(username)
    except Exception as e:
        print("Erro ao criar usuário:", e)
    return None


def initiate_auth(username):
    try:
        return cognito.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username,
                'PASSWORD': username
            },
            ClientId=cognito_client_id
        )
    except cognito.exceptions.NotAuthorizedException as e:
        print("Usuário não autorizado.", e)
        return None
    except Exception as e:
        print("Erro ao fazer login:", e)
        return None
