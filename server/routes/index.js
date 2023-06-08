var express = require('express');
var router = express.Router();
var mysql = require("mysql");
var bodyParser = require('body-parser');
var jwt = require("jsonwebtoken");
//var authUtil = require('../middlewares/auth').checkToken

var api = express();
api.use(bodyParser.json());
api.use(bodyParser.urlencoded({extended: true}));

var con = mysql.createConnection({
    host: 'api-db.c9oc7ghuiylx.ap-northeast-2.rds.amazonaws.com',
    user: 'admin',
    password: 'neptune2580',
    database: 'information'
});

con.connect();

/* GET 'home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

//회원가입 (회원 정보 입력)

router.post("/api/triton/members/join", function(req, res) {
  //console.log(req.body);
 
  var idx = req.body.idx;
  var email = req.body.email;
  var tel = req.body.tel;
  var pass = req.body.pass;
  var kg = req.body.kg;
  var kii = req.body.kii;


    var sql = "INSERT INTO members (idx, email, tel, pass, kg, kii) VALUES ('"+ idx +"', '"+ email +"', '"+ tel +"', '"+ pass +"','"+ kg +"','"+ kii +"')";
      con.query(sql, function(err,result) {
        if(err) throw err;
      console.log("1 recored inserted");
      res.send("successfully recored inserted");
    });
  
});



//회원 정보 보내기(앱 요청 시)
router.get('/api/triton/members/get', function(req, res, next) {
  var gid = req.query.id;
  console.log(gid);


  var query = "Select * FROM members WHERE id ="+gid;
  con.query(query, function(err, result){
    if(err) throw err;
    console.log(result);
    res.send(result);
  });

});

//로그인(id, pass 비교 후 0,1 리턴)


router.post('/api/triton/login', function (req, res){
  console.log("login res:"+req.body);
  var lemail = req.body.email;
  var lpass = req.body.pass;
  var lsql = 'SELECT * FROM members WHERE email = ?';

  console.log(req.body.email);

  con.query(lsql, lemail, function (err, result){
    var resultCode = 404;
    var message = '에러가 발생했습니다.';
    
    if (err) {
      console.log(err);
    } else {
      if (result.length === 0){
        resultCode = 204;
        message = '0';
      } else if (lpass !== result[0].pass){
        resultCode = 204;
        message = '0';
      } else {

      /*  const token = jwt.sign({ user: {'email': lemail} }, 'dsfklgj');
        res.json({jwt: token});

        //var refreshToken = jwt.sign({},
        //  'wmp secret', {
        //  expiresIn: '14d',
        //  issuer: 'wmp server'
        //},
        
        //);
        
        console.log("토큰생성\n", token);
        */
        //console.log("리프레쉬 토큰 생성\n", refreshToken);
        resultCode = 200;
        message = result;
      }
    }
    //res.json({
    //  'result': message,
    //  'token': token,
    //  'refresh': refreshToken
    //});
  })
});
/*
//토큰 검증
router.post('/api/triton/login/verify',function(req, res){
    const token = req.body.jwt;
    const x = jwt.verify(token, 'dsfklgj', function (err, decoded) {
    if (err) throw err;
    console.log(decoded);
    });
    if (x != true) {
    res.json({ auth: false });
    }else {
    res.json({ auth: true });
    }
    });
*/
//토큰 생성
/*
router.get('/api/triton/login/jwt', function (req,res){

  var token=jwt.sign({
    pcweb  : "pcweb" //Private Claim 자리
  },
  "secretKey", //비밀키가 들어갈 자리 Signature
  {
    subject: "wmp jwtToken", //Public Claim (토큰제목)
    expiresIn: "60m", //만료시간
    issuer: "wmp server" //발급자
  });
  console.log("토큰생성\n", token);
  return res.json(token);
});
*/

//운동 기록, 날짜 입력 (아두이노에서 받기)

router.post("/api/triton/members/health", function(req, res) {

  function isEmptyObj(obj) {
    if(obj.constructor === Object && Object.keys(obj).length === 0) {
      return true;
    } else {
      return false;
    }
  }

  var healthData = {
    hemail: req.body.email,
    x: req.body.x,
    y: req.body.y,
    z: req.body.z,
    pose: req.body.pose  
  };

  
  if(isEmptyObj(healthData) == true) {
    throw new Error("Value is Empty");
  } else {
    var hsql = "INSERT INTO health (email, x, y, z, pose) VALUES ('"+ healthData.hemail +"', '"+ healthData.x +"', '"+ healthData.y +"', '"+ healthData.z +"', '"+ healthData.pose +"')";
      con.query(hsql, function(err,result) {
        if(err) throw err;
        console.log("1 recored inserted");
        res.send("successfully recored inserted"); 
      });
  } 
  
  
});

//앱에서 요청하면 운동정보와 회원정보를 한번에 보냄
router.get('/api/triton/members/info', function(req, res, next) {
  var jemail = req.body.email;
  

  var join = "SELECT * FROM members INNER JOIN health ON members.email = health.email WHERE members.email = '"+jemail+"' ";
  con.query(join, function(err, result){
  if(err) throw err;
  console.log(result);
  res.json(result);
  });

});

//운동 시간 인서트
router.post("/api/triton/worktime", function(req, res, next){
  /*var wemail = req.body.email;
  var starttime = req.body.starttime;
  var endtime = req.body.endtime;
  */
  var times = {
    starttime: req.body.starttime,
    endtime: req.body.endtime,
  };
  var extime = times.endtime - times.starttime;

  var hour = parseInt(extime/3600);
  var min = parseInt((extime%3600)/60);
  var sec = extime%60;

  var spendtime = +hour+":"+min+":"+sec;

  console.log(spendtime);
  

  var inworktime = "INSERT INTO worktime (starttime, endtime, extime) VALUES ('"+ times.starttime +"', '"+ times.endtime +"', '"+spendtime+"')";
    con.query(inworktime, function(err,result) {
    if(err) throw err;
    console.log("1 recored inserted");
    res.send("successfully recored inserted");
  });
});

//운동 시간 보내기
router.get('/api/triton/worktime/call', function(req, res, next) {

  var selectworktime = "Select extime FROM worktime ORDER BY totalnum desc LIMIT 1";
  con.query(selectworktime, function(err, result){
    if(err) throw err;
    console.log(result);
    res.json(result);
  });

});

module.exports = router;
