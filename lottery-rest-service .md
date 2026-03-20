

###Signin
- HTTP Method : POST
- URL : {API end point}/api/auth/signin

_Request :_
```$xslt
{
"userName": "user1",
"password": "user1@test",
"appId": 1,
"loginType": "mobile", //mobile, desktop, web
"macAddress": "dsafd21324989",
"deviceReference": "Mi y3 android 8 lollypop"
}
```
_Response :_
```$xslt
{
"userName": "user1",
"balance": 24000.00,
"status": 1, //0-inactive, 1-active, 2-suspended
"passwordChange": 0, //0-not needed, 1-change password
"gameList": [{
        "categoryId": 1,
        "categoryName": "Lotteries",
        "categoryOrder": 1,
        "categoryStatus": 1,
        "categoryGames": [{
            "gameName": "WIN-WIN",
            "gameId": "winwin-mon",
            "digits": 6,
            "price": 40.00,
            "winPrice": 100000.00,
            "status": 1,
            "drawId": "WW643223",
            "drawStartTime": 1650810092647,
            "betCloseTime": 1650810082647
        }, {
        .........
        }
        ]
    }, {
    .........
    }, {
    .........
    }],
"currentTime":1650810092647
}
```

###Signout
- HTTP Method : POST
- URL : {API end point}/api/auth/signout

_Request :_
```$xslt
{
}
```
_Response :_
```$xslt
{
"errorCode": 0
}
```

###Balance
- HTTP Method : POST
- URL : {API end point}/api/user/balance

_Request :_
```$xslt
{
}
```
_Response :_
```$xslt
{
"balance": 24000.00,
"errorCode": 0
}
```

###Change password
- HTTP Method : POST
- URL : {API end point}/api/user/changePassword

_Request :_
```$xslt
{
"oldPassword": "user1@test",
"newPassword": "user1@test123",
"macAddress": "dsafd21324989",
"deviceReference": "Mi y3 android 8 lollypop"
}
```
_Response :_
```$xslt
{
"errorCode": 0
}
```

###Category
- HTTP Method : POST
- URL : {API end point}/api/lotto/category

_Request :_
```$xslt
{
}
```
_Response :_
```$xslt
{
"categoryList": [{
        "categoryId": 1,
        "categoryName": "Lotto",
        "categoryOrder": 1,
        "categoryStatus": 1
    }, {
    .........
    }, {
    .........
    }],
"errorCode": 0
}
```

###Games
- HTTP Method : POST
- URL : {API end point}/api/lotto/games

_Request :_
```$xslt
{
   "categoryId": 1
}
```
_Response :_
```$xslt
{
"gameList": [{
        "gameName": "WIN-WIN",
        "gameId": "winwin-mon",
        "digits": 6,
        "price": 40.00,
        "id": 10001,
        "gameOrder":1,
        "status": 1
    }, {
    .........
    }, {
    .........
    }],
"errorCode": 0
}
```

###Lobby
- HTTP Method : POST
- URL : {API end point}/api/lotto/lobby

_Request :_
```$xslt
{
}
```
_Response :_
```$xslt
{
"gameList": [{
        "categoryId": 1,
        "categoryName": "Lotto",
        "categoryStatus": 1,
        "categoryGames": [{
            "gameName": "WIN-WIN",
            "gameId": "winwin-mon",
            "digits": 6,
            "price": 40.00,
            "winPrice": 100000.00,
            "status": 1,
            "drawId": "WW643223",
            "drawStartTime": 1650810092647,
            "betCloseTime": 1650810082647
        }, {
        .........
        }
        ]
    }, {
    .........
    }, {
    .........
    }],
"currentTime":1650810092647,
"errorCode": 0
}
```

###gameInit
- HTTP Method : POST
- URL : {API end point}/api/lotto/gameInit

_Request :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223"
}
```
_Response :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223",
"gameName": "WIN-WIN",
"digits": 6,
"price": 40.00,
"winPrice": 100000.00,
"status": 1,
"drawStartTime": 1650810092647,
"betCloseTime": 1650810082647,
"ticketNos": ["123456", "678901", "109876" , "654321", "543210"],
"balance": 9200.00,
"errorCode": 0
}
```

###gameInit
- HTTP Method : POST
- URL : {API end point}/api/lotto/gameWinPrice

_Request :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223"
}
```
_Response :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223",
"winPrices": [{
        "id": 12345,
        "name": "1st prize",
        "winPrice": 100000.00,
        "winOrder": 1,
        "totalNumbers": 1 
    }, {
    .........
    }, {
    .........
    }],
"errorCode": 0
}
```

###Ticket quick pick
- HTTP Method : POST
- URL : {API end point}/api/lotto/ticketQuickPick

_Request :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223",
"nos": 5
}
```
_Response :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223",
"nos": 5,
"ticketNos": ["123456", "678901", "109876" , "654321", "543210"],
"errorCode": 0
}
```

###Search ticket
- HTTP Method : POST
- URL : {API end point}/api/lotto/searchTicket

_Request :_
```$xslt
{
"gameId": "winwin-mon",
"drawId": "WW643223",
"ticketNo": "12345*" //1234** or 123*** or 123456
}
```
_Response :_
```$xslt
{
"gameId": "winwin-mon",
"drawId": "WW643223",
"tickets": [
    "123450-1", //"ticketNo-status" (status : 0-notavilable, 1-available)
    "123451-1",
    "123452-0",
    "123453-0",
    "123454-1",
    "123455-1",
    "123456-0",
    "123457-1",
    "123458-1",
    "123459-1",
    ],
"errorCode": 0
}
```

###Buy ticket
- HTTP Method : POST
- URL : {API end point}/api/lotto/buyTicket

_Request :_
```$xslt
{
"gameId": "winwin-mon",
"drawId": "WW643223",
"ticketNos": [
    "123450",
    "123451",
    "123459"
    ]
}
```
_Response :_
```$xslt
{
"gameName": "WIN-WIN",
"gameId": "winwin-mon",
"drawId": "WW643223",
"drawStartTime": "1650810092647",
"price": 5.00,
"ticketCount": 3,
"ticketPrice": 15.00,
"balance": 23670.00,
"internalRefNo": "abfzs324",
"tickets": [
    "123450-1-abfzs324f", //"ticketNo-status-refno" (status : 0-already sold, 1-bought)
    "123451-0-",
    "123459-1-abfzs324g"
],
"errorCode": 0
}
```

###Result
- HTTP Method : POST
- URL : {API end point}/api/lotto/result

_Request :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"from": 1650810092647,
"to": 1650810392647
}
```
_Response :_
```$xslt
{
"results": [
    {
        "gameName": "WIN-WIN",
        "gameId": "winwin-mon",
        "drawId": "WW643223",
        "price": 40.00,
        "winPrice": 100000.00,
        "drawStartTime": "1650810092647"
    },{
    ...........
    },{
    ...........
    }],
"errorCode": 0
}
```

###Draw result
- HTTP Method : POST
- URL : {API end point}/api/lotto/drawResult

_Request :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223"
}
```
_Response :_
```$xslt
{
"results": [
    {
        "id": 12345,
        "name": "1st prize",
        "winPrice": 100000.00,
        "ticketNos": ["165082"]
    },{
        "id": 12347,
        "name": "2nd prize",
        "winPrice": 50000.00,
        "ticketNos": ["165082", "165028"]
    },{
    ...........
    }
],
"errorCode": 0
}
```

###User result
- HTTP Method : POST
- URL : {API end point}/api/lotto/userResult

_Request :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"resultType": 1, //1-To be drawn, 2-drawn, 3-won
"page": 0, 
"from": 1650810092647,
"to": 1650810392647
}
```
_Response :_
```$xslt
{
"results": [
    {
        "gameName": "WIN-WIN",
        "gameId": "winwin-mon",
        "drawId": "WW643223",
        "ticketNo": "165082",
        "time": 1650810092647,
        "status": 1, //1-bet placed, 2-bet cancelled, 3-bet lose, 4-bet won
        "claim": 0, //0-not claimed, 1-claimed already
        "winName": "1st prize",
        "winPrice": 100000.00
    },{
        "gameName": "WIN-WIN",
        "gameId": "winwin-mon",
        "drawId": "WW643223",
        "ticketNo": "165028",
        "time": 1650810092647,
        "status": 1,
        "claim": 0,
        "winName": "1st prize",
        "winPrice": 100000.00
    },{
    ...........
    }
],
"page": 1, 
"totalPages": 10, 
"errorCode": 0
}
```

###Claim
- HTTP Method : POST
- URL : {API end point}/api/lotto/claim

_Request :_
```$xslt
{
"categoryId": 1,
"gameId": "winwin-mon",
"drawId": "WW643223",
"ticketNo": "165028"
}
```
_Response :_
```$xslt
{
"balance": 125600.00,
"errorCode": 0
}
```

###Error Codes
- 0 - Success
- 1 - General Error
- 2 - Game not found
- 3 - Old password is wrong
- 4 - Bet closed
- 5 - Ticket not accepted
- 6 - Ticket not found
- 7 - Insufficient fund
- 8 - Transaction not found
- 9 - Draw result under in progress
- 10 - Already claimed
- 11 - Tickets not available for this range
- 12 - Old password doesn't match our records
- 13 - Draw is not started
- 14 - Draw is already completed
- 15 - No bets allowed for this draw due to bet time not started
- 16 - No bets allowed for this draw due to bet time is over
- 17 - Invalid ticket no
- 18 - Draw is not completed
- 19 - Claim not allowed due to win is zero
- 20 - Claim not allowed due to bet cancelled already

###HTTP Status code
- 200 - OK
- 400 - Bad Request
- 401 - Unauthorized

####Note : Except signin all other request must set lottoapp=****** in request header (lottoapp=****** is received in signin response header)