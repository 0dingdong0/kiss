import re
import jwt
import hashlib

from datetime import datetime, timedelta

from fastapi import FastAPI, Body, Request
from pydantic import BaseModel

from aiographql.client import GraphQLClient
from aiographql.client.request import GraphQLRequest
from aiographql.client.response import GraphQLResponse


SECRET = 'sSRiJYUp1Z_JqN6xqU7y0ohOC42H_D0X1AYjvUktO7c'

client = GraphQLClient(
    endpoint = "http://192.168.1.182:8080/v1/graphql",
    headers = {"X-Hasura-Admin-Secret": "tbqIwPZ_7rw"}
)

app = FastAPI()

@app.middleware("http")
async def process_input_args(request: Request, call_next):
    return await call_next(request)

class Credentials(BaseModel):
    loginId : str
    password : str

class UserInfo(BaseModel):
    userId: str
    accessToken: str

@app.post('/login/')
async def login(req = Body(...)) -> UserInfo:

    credentials = req['input']['credentials']
    
    # print('***************************************')
    # print(Credentials.parse_obj(credentials).json())
    # print(credentials['password'], credentials['loginId'])

    loginId = credentials['loginId']
    password = credentials['password']

    hl=hashlib.md5()
    hl.update(password.encode(encoding='utf-8'))
    password = hl.hexdigest()

    
    request = GraphQLRequest(
	    query="""
            query($loginId: String, $password: String) {
                staff(where: {
                    _and: [
                        {_or: [
                            {email: {_eq: $loginId}},
                            {mobile: {_eq: $loginId}}
                        ]}, 
                        {password: {_eq: $password}}
                    ]
                }){
                    id
                    title
                    is_active
                    joined_at
                    last_name
                    first_name
                    default_role
                    allowed_roles {
                        role
                        created_by
                        created_at
                        staff
                    }
                }
            }
	    """,
	    variables={
            "loginId": loginId,
            "password": password
        }
	)

    response:GraphQLResponse = await client.query(request=request)

    if response.errors:
        raise Exception(response.errors)

    if len(response.data['staff']) != 1:
        raise Exception('Authentication failed! Please try again ...')

    user = response.data['staff'][0]
    # print('------------------------', user)

    now = datetime.now()
    exp = now + timedelta(hours=1)

    payload = {
        "sub": "authentication",
        "name": user['last_name']+' '+user['first_name'],
        "admin": "true",
        "iss": "http://192.168.1.182:8000/login/",
        "iat": int(now.timestamp()),
        "exp": int(exp.timestamp()),
        "https://hasura.io/jwt/claims": {
            "x-hasura-allowed-roles": [ role['role'] for role in user['allowed_roles'] ],
            "x-hasura-default-role": user['default_role'],
            "x-hasura-user-id": user['id'],
        }
    }

    token = jwt.encode(payload, SECRET, algorithm='HS256')

    print('===========================', payload)
    return {
        "userId": user['id'],
        "accessToken": token
    }