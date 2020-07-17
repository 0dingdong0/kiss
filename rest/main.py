import re
import hashlib

from fastapi import FastAPI, Body, Request
from pydantic import BaseModel

from aiographql.client import GraphQLClient
from aiographql.client.request import GraphQLRequest
from aiographql.client.response import GraphQLResponse

client = GraphQLClient(
    endpoint = "http://192.168.1.182:8080/v1/graphql",
    headers = {}
)

app = FastAPI()

class Credentials(BaseModel):
    loginId : str
    password : str

class UserInfo(BaseModel):
    userId: str
    accessToken: str

@app.post('/login/')
async def login(req = Body(...)) -> UserInfo:

    credentials = req['input']['credentials']
    print(Credentials.parse_obj(credentials).json())
    print(credentials['password'], credentials['loginId'])

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

    print('------------------------', response.data)

    return {
        "userId": 123,
        "accessToken": 'lskdflskjfhknckwheoiflksf'
    }