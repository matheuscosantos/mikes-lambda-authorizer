# Lambda Handler: Autenticação Cognito

Este Lambda function gerencia o processo de autenticação para um pool de usuários Cognito. Ele recebe uma solicitação contendo um CPF do usuário e tenta registrar o usuário usando o método `sign_up` do Cognito. Se o usuário for registrado com sucesso, ele inicia o processo de autenticação usando `initiate_auth` e retorna a resposta de autenticação.

[Desenho da arquitetura](https://drive.google.com/file/d/12gofNmXk8W2QnhxiFWCI4OmvVH6Vsgun/view?usp=drive_link)

## Variáveis de Ambiente

- `COGNITO_CLIENT_ID`: O ID do cliente do pool de usuários do Cognito.
- `COGNITO_USER_POOL_ID`: O ID do pool de usuários do Cognito.
- `COGNITO_ADMIN_USERNAME`: O nome de usuário do administrador para o pool de usuários do Cognito.

## Estrutura do Evento

A função espera uma solicitação HTTP com um payload JSON contendo o CPF do usuário:

```json
{
  "body": "{\"cpf\":\"12345678900\"}"
}
```

## Resposta

A função retorna um objeto JSON com a seguinte estrutura:

statusCode: O código de status HTTP da resposta.
body: Um objeto JSON contendo uma mensagem e a resposta de autenticação.

Exemplo de resposta bem-sucedida:

```json
{
  "statusCode": 200,
  "body": "{\"message\":\"Usuário autenticado com sucesso\",\"response\":{\"AuthenticationResult\":{...}}}"
}
```

Exemplo de resposta não autorizada:

```json
{
  "statusCode": 401,
  "body": "{\"message\":\"Usuário não autorizado\"}"
}
```

Exemplo de resposta de erro desconhecido:

```json
{
"statusCode": 500,
"body": "{\"message\":\"Erro desconhecido: ...\"}"
}
```

## Dependências
- boto3
- botocore
- requests
- requests-aws4auth

## Notas Adicionais

Esta função assume que o CPF é um nome de usuário válido para o Cognito. Ajustes podem ser necessários com base em seus requisitos específicos e configurações do Cognito.
O tratamento de erros é simplificado para fins de demonstração. Modifique conforme necessário para sua aplicação.