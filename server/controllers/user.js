const jwt = require('../modules/jwt');

signin : async ( req, res ) => {
   /* user정보를 DB에서 조회 */
  const user = await User.getUserByEmail(email);
  /* user의 idx, email을 통해 토큰을 생성! */
  const jwtToken = await jwt.sign(user);
  return res.status(statusCode.OK).send(util.success(statusCode.OK, responseMsg.LOGIN_SUCCESS, {
       /* 생성된 Token을 클라이언트에게 Response */
        token: jwtToken.token
    }))
}