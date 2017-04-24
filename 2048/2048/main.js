/**
 * Created by BoBo_mini on 17/3/20.
 */
//第五个参数是state对象,可以单独定义,然后绑定到game上
var game = new Phaser.Game(240, 400, Phaser.CANVAS, 'game');

var score = 0;
var scoreText;

//配置敌机相关参数
function Enemy(config) {
    this.init = function() {
        //生成敌机
        this.enemys = game.add.group();
        this.enemys.enableBody = true;

        this.lastEnemyBtime = 0;
        //生成敌机的子弹
        this.enemyBullets = game.add.group();
        this.enemyBullets.enableBody = true;
        this.enemyBullets.createMultiple(config.bulletPool, config.bulletPic);
        this.enemyBullets.setAll('outOfBoundsKill', true);
        this.enemyBullets.setAll('checkWorldBounds', true);

        //确定敌机出现X方向的最大范围
        this.maxWidth = game.width - game.cache.getImage(config.selfPic).width;

        //使用定时器来随机产生敌机
        game.time.events.loop(Phaser.Timer.SECOND * game.rnd.integerInRange(1, 5), this.generateEnemy, this);

        //敌机爆炸效果
        this.explosions = game.add.group();
        this.explosions.createMultiple(config.explodePool, config.explosionPic);
        this.explosions.forEach(function(explosion) {
            explosion.animations.add(config.explosionPic);
        }, this);
    }

    //生成敌机
    this.generateEnemy = function() {
        //随机生成新出现敌机的x坐标
        var x = game.rnd.integerInRange(0, this.maxWidth);
        var y = game.cache.getImage(config.selfPic).height;
        //使用该方法,当数组中数量不够时会自动创建
        var enemy = this.enemys.getFirstExists(false, true, x, -y, config.selfPic, false);
        enemy.outOfBoundsKill = true;
        enemy.checkWorldBounds = true;
        enemy.life = config.life;
        enemy.body.velocity.y = config.velocity;
    }

    //敌机开火
    this.enemyFire = function() {
        this.enemys.forEachExists(function(enemy) {
            var bullet = this.enemyBullets.getFirstExists(false);
            if (bullet) {
                if (game.time.now > (enemy.lastEnemyBtime || 0)) {
                    bullet.reset(enemy.x + config.bulletX, enemy.y + config.bulletY);
                    bullet.body.velocity.y = config.bulletVelocity;
                    enemy.lastEnemyBtime = game.time.now + 1000; //config.bulletTimeInterval;
                }
            }
        }, this);
    }

    //敌机被打中
    this.hitEnemy = function(mybullet, enemy) {
        try {
            config.firesound.play();
        } catch (error) {}

        mybullet.kill();
        enemy.life --;
        if (enemy.life <= 0) {
            try {
                config.crashSound.play();
            } catch (error) {}

            enemy.kill();

            //生成爆炸效果
            var explosion = this.explosions.getFirstExists(false);
            explosion.reset(enemy.body.x, enemy.body.y);
            explosion.play(config.explosionPic, 30, false, true);
            score += config.score;
            scoreText.text = 'score: '+ score;
        }
    }

    //我方飞机被击中
    this.bulletHitMyPlane = function(myplane, enemyBullet) {
        enemyBullet.kill();
        myplane.level --;
        if (myplane.level <= 0) {
            myplane.kill();
            game.state.start('over');
        }
    }

    //我方飞机被撞
    this.hitMyplane = function(myplane, enemy) {
        enemy.kill();
        myplane.level --;
        if (myplane.level <= 0){
            myplane.kill();
            game.state.start('over');
        }
    }
}

//TODO:  游戏场景相关
game.MyStates = {};
//boot state:一般是对游戏进行一些设置,本例是用于加载进度条资源
game.MyStates.boot = {
    preload: function() {
        game.load.image('preload', 'assets/preloader.gif');
        if (!game.device.desktop) { //判断是否在PC上运行
            //在boot场景里面进行屏幕适配,使用ScaleManager进行屏幕适配
            game.scale.scaleMode = Phaser.ScaleManager.EXACT_FIT;
        }
    },
    create: function() {
        game.state.start('load');
    }
};

//load state,一般用于加载资源
game.MyStates.load = {
    preload: function () {
        //创建精灵, 前两个参数是位置参数
        var preloadSprite = game.add.sprite(game.width/2 - 220/2, game.height/2 - 19/2, 'preload');
        //设置锚点
        // preloadSprite.anchor.set(0.5, 0.5);
        game.load.setPreloadSprite(preloadSprite);
        //加载背景图
        game.load.image('background', 'assets/bg.jpg');
        game.load.image('copyright', 'assets/copyright.png');
        //使用spritesheet加载序列帧的动画,第三个和第四个参数指定每帧图片的大小,第五个参数指定帧的数量
        game.load.spritesheet('myplane', 'assets/myplane.png', 40, 40, 4);
        game.load.spritesheet('startbutton', 'assets/startbutton.png', 100, 40, 2);
        game.load.spritesheet('replaybutton', 'assets/replaybutton.png', 80, 30, 2);
        game.load.spritesheet('sharebutton', 'assets/sharebutton.png', 80, 30, 2);
        game.load.image('mybullet', 'assets/mybullet.png');
        game.load.image('bullet', 'assets/bullet.png');
        game.load.image('enemy1', 'assets/enemy1.png');
        game.load.image('enemy2', 'assets/enemy2.png');
        game.load.image('enemy3', 'assets/enemy3.png');
        game.load.spritesheet('explode1', 'assets/explode1.png', 20, 20, 3);
        game.load.spritesheet('explode2', 'assets/explode2.png', 30, 30, 3);
        game.load.spritesheet('explode3', 'assets/explode3.png', 50, 50, 3);
        game.load.spritesheet('myexplode', 'assets/myexplode.png', 40, 40, 3);
        game.load.image('award', 'assets/award.png');
        //使用audio加载音频文件,参数和加载普通图片是一样的
        game.load.audio('normalback', 'assets/normalback.mp3');
        game.load.audio('playback', 'assets/playback.mp3');
        game.load.audio('fashe', 'assets/fashe.mp3');
        game.load.audio('crash1', 'assets/crash1.mp3');
        game.load.audio('crash2', 'assets/crash2.mp3');
        game.load.audio('crash3', 'assets/crash3.mp3');
        game.load.audio('ao', 'assets/ao.mp3');
        game.load.audio('pi', 'assets/pi.mp3');
        game.load.audio('deng', 'assets/deng.mp3');
        //通过回调来准确的获得加载百分比
        game.load.onFileComplete.add(function(process) {
            // console.log(arguments); //可以查看中间加载了多少个文件

        })
    },
    create: function () {
        game.state.start('start');
    },
    update: function () {

    }
};

//start state,游戏开始界面
game.MyStates.start = {
    create: function () {
        game.add.sprite(0, 0, "background");
        //或者使用image
        //game.add.sprite(0, 0, 'background');
        game.add.image(12, game.height - 16, 'copyright');
        var myplane = game.add.sprite(100, 100, 'myplane');
        myplane.animations.add('fly');
        //第一个参数是上面添加的动画名称, 第二个参数控制帧动画的速率,第三个参数控制动画是否循环
        myplane.animations.play('fly', 12, true);

        //添加按钮
        game.add.button(70, 200, 'startbutton',this.onStartClick, this, 1, 1, 0);

        //添加开始的背景音乐
        this.normalback = game.add.audio('normalback', 0.2, true);
        this.normalback.play();
    },

    //按钮点击事件
    onStartClick: function() {
        //跳转到游戏场景
        game.state.start('play');
        //停止播放开始音乐
        this.normalback.stop();
    }
};

//play state, 游戏主界面,主要的游戏逻辑
game.MyStates.play = {
    create: function () {
        //打开ARCADE物理引擎
        game.physics.startSystem(Phaser.Physics.ARCADE);
        //背景滚动
        var bg = game.add.tileSprite(0, 0, game.width, game.height, 'background');
        //背景自动滚动,两个参数分别控制宽度和高度的滚动范围
        bg.autoScroll(0, 20);

        //逐帧动画,  我方飞机
        this.myplane = game.add.sprite(100, 100, 'myplane');
        this.myplane.animations.add('fly');
        this.myplane.animations.play('fly', 12, true);
        //打开飞机的物理引擎
        game.physics.arcade.enable(this.myplane);
        this.myplane.body.collideWorldBounds = true;
        this.myplane.level = 3;

        //界面刚开始时,飞机飞到底部,渐变动画
        var tween = game.add.tween(this.myplane).to({y: game.height - 40}, 1000, null, true);
        //给渐变动画添加动效
        tween.onComplete.add(this.onStart, this);

        //背景音乐,一直在播放,直至飞机挂掉
        this.playback = game.add.audio('playback', 0.2, true);
        //播放背景音乐
        this.playback.play();

        //开火音乐
        this.pi = game.add.audio('pi', 1, false);

        //打中敌人音乐
        this.firesound = game.add.audio('fashe', 5, false);

        //爆炸音乐
        this.crash1 = game.add.audio('crash1', 10, false);
        this.crash2 = game.add.audio('crash2', 10, false);
        this.crash3 = game.add.audio('crash3', 20, false);

        //挂掉音乐
        this.ao = game.add.audio('ao', 10, false);

        //接到了奖音乐
        this.deng = game.add.audio('deng', 10, false);
    },

    update: function() {
        if (this.myplane.myStartFire) {
            //我方飞机发射子弹
            this.myPlaneFire();
            //敌机开火
            this.enemy1.enemyFire();
            this.enemy2.enemyFire();
            this.enemy3.enemyFire();

            //添加子弹和敌机的碰撞处理
            //game.physics.arcade.collide(this.myBullets, this.enemy, this.collisionHandler, null, this);
            //TODO overlap用于碰撞检测,可将overlap替换成collide来查看两者的具体区别
            game.physics.arcade.overlap(this.myBullets, this.enemy1.enemys, this.enemy1.hitEnemy, null, this.enemy1);
            game.physics.arcade.overlap(this.myBullets, this.enemy2.enemys, this.enemy2.hitEnemy, null, this.enemy2);
            game.physics.arcade.overlap(this.myBullets, this.enemy3.enemys, this.enemy3.hitEnemy, null, this.enemy3);
            //敌机击中我方飞机
            game.physics.arcade.overlap(this.myplane, this.enemy1.enemyBullets, this.enemy1.bulletHitMyPlane, null, this.enemy1);
            game.physics.arcade.overlap(this.myplane, this.enemy2.enemyBullets, this.enemy2.bulletHitMyPlane, null, this.enemy2);
            game.physics.arcade.overlap(this.myplane, this.enemy3.enemyBullets, this.enemy3.bulletHitMyPlane, null, this.enemy3);
            //飞机与敌机相撞
            game.physics.arcade.overlap(this.myplane, this.enemy1.enemys, this.enemy1.hitMyplane, null, this.enemy1);
            game.physics.arcade.overlap(this.myplane, this.enemy2.enemys, this.enemy2.hitMyplane, null, this.enemy2);
            game.physics.arcade.overlap(this.myplane, this.enemy3.enemys, this.enemy3.hitMyplane, null, this.enemy3);

            //获得奖励
            game.physics.arcade.overlap(this.myplane, this.awards, this.getPlaneAward, null, this);

        }
    },

    //游戏开始
    onStart: function() {
        //允许鼠标拖拽精灵
        this.myplane.inputEnabled = true;
        this.myplane.input.enableDrag(false);
        //自定义变量,用来标记飞机可以发射子弹
        this.myplane.myStartFire = true;
        //自定义变量,用来控制子弹发射时间
        this.myplane.lastBulletTime = 0;
        //创建子弹group
        this.myBullets = game.add.group();
        //起初创建5颗子弹
        // this.myBullets.createMultiple(5, 'mybullet');
        //开启group的物理引擎
        this.myBullets.enableBody = true;
        //为了回收子弹
        // this.myBullets.setAll('outOfBoundsKill', true);
        // this.myBullets.setAll('checkWorldBounds', true);

        //创建奖励
        this.awards = game.add.group();
        this.awards.enableBody = true;
        this.awards.createMultiple(1, 'award');
        this.awards.setAll('outOfBoundsKill', true);
        this.awards.setAll('checkWorldBounds', true);
        //获取'奖励'图片的最大宽度
        this.awardMaxWidth = game.width - game.cache.getImage('award').width;
        //类似iOS的定时器
        game.time.events.loop(Phaser.Timer.SECOND * game.rnd.integerInRange(10, 15), this.generateAward, this);

        //显示游戏的分数
        var style = { font: "16px Arial", fill: "#ff0295"};
        scoreText = game.add.text(0, 0, "Score: 0", style);

        //敌机
        var enemyTeam = {
            enemy1: {
                game: this,
                selfPic: 'enemy1',
                bulletPic: 'bullet',
                explosionPic: 'explode1',
                selfPool: 10,
                bulletPool: 50,
                explodePool: 10,
                life: 2,
                velocity: 50,
                bulletX: 9,
                bulletY: 20,
                bulletVelocity: 200,
                selfTimeInterval: 2,
                bulletTimeInterval: 1000,
                score: 10,
                fireSound: this.firesound,
                crashSound: this.crash1
            },
            enemy2: {
                game: this,
                selfPic: 'enemy2',
                bulletPic: 'bullet',
                explosionPic: 'explode2',
                selfPool: 10,
                bulletPool: 50,
                explodePool: 10,
                life: 3,
                velocity: 40,
                bulletX: 13,
                bulletY: 30,
                bulletVelocity: 250,
                selfTimeInterval: 3,
                bulletTimeInterval: 1200,
                score: 20,
                fireSound: this.firesound,
                crashSound: this.crash2
            },
            enemy3: {
                game: this,
                selfPic: 'enemy3',
                bulletPic: 'bullet',
                explosionPic: 'explode3',
                selfPool: 5,
                bulletPool: 25,
                explodePool: 5,
                life: 10,
                velocity: 30,
                bulletX: 22,
                bulletY: 50,
                bulletVelocity: 300,
                selfTimeInterval: 10,
                bulletTimeInterval: 1500,
                score: 50,
                fireSound: this.firesound,
                crashSound: this.crash3
            }
        };

        this.enemy1 = new Enemy(enemyTeam.enemy1);
        this.enemy1.init();
        this.enemy2 = new Enemy(enemyTeam.enemy2);
        this.enemy2.init();
        this.enemy3 = new Enemy(enemyTeam.enemy3);
        this.enemy3.init();
    },

    //更新分数
    updateText: function() {

    },

    //生成奖励的函数
    generateAward: function() {
        var x = game.rnd.integerInRange(0, this.awardMaxWidth);
        var y = game.cache.getImage('award').height;
        var award = this.awards.getFirstExists(false, true, x, y, 'award', false);
        award.outOfBoundsKill = true;
        award.checkWorldBounds = true;
        //TODO  如果奖励不能移动可能是此处为开启物理引擎
        award.body.velocity.y = 200;
    },

    //获得奖励
    getPlaneAward: function(myplane, award) {
        award.kill();
        myplane.level ++;
    },

    //生成子弹
    myPlaneFire: function() {
        //获取当前时间
        var now = new Date().getTime();// game.time.now;
        if (now - this.myplane.lastBulletTime > 300) { //每隔500毫秒发射一颗子弹
            //播放子弹发射的声音
            try {
                this.pi.play();
            } catch(e) {}

            //从group里面获取一个对象
            var myBullet;
            myBullet = this.myBullets.getFirstExists(false); //false表示未显示在屏幕上的子弹,true表示显示在屏幕上的子弹
            if (myBullet) { //从group里面获取到了数据
                //从组里面获取子弹之后,重新调整位置
                myBullet.reset(this.myplane.x + 15, this.myplane.y - 7);
            } else { //没有从group获取到,创建一个new bullet
                //new一个bullet
                myBullet = game.add.sprite(this.myplane.x + 15, this.myplane.y - 7, 'mybullet');
                myBullet.outOfBoundsKill = true;
                myBullet.checkWorldBounds = true;
                //将发射过的子弹添加到group中去
                this.myBullets.addChild(myBullet);
                game.physics.enable(myBullet, Phaser.Physics.ARCADE);
            }
            //设置y方向的速度
            myBullet.body.velocity.y = -500;
            this.myplane.lastBulletTime = now;

            //不同的等级具有不同的威力
            if (this.myplane.level >= 2) {
                var rightTwoBullet = this.myBullets.getFirstExists(false, true, this.myplane.x + 15, this.myplane.y - 7, 'mybullet', false);
                    rightTwoBullet.body.velocity.y = -500;
                    rightTwoBullet.body.velocity.x = 40;
                    rightTwoBullet.outOfBoundsKill = true;
                    rightTwoBullet.checkWorldBounds = true;
                    this.myplane.lastBulletTime = now;

                var leftTwoBullet = this.myBullets.getFirstExists(false, true, this.myplane.x + 15, this.myplane.y - 7, 'mybullet', false);
                    leftTwoBullet.body.velocity.y = -500;
                    leftTwoBullet.body.velocity.x = -40;
                    leftTwoBullet.outOfBoundsKill = true;
                    leftTwoBullet.checkWorldBounds = true;
                    this.myplane.lastBulletTime = now;
            }

            if (this.myplane.level >= 3) {

                var rightThreeBullet = this.myBullets.getFirstExists(false, true, this.myplane.x + 15, this.myplane.y - 7, 'mybullet', false);
                rightThreeBullet.body.velocity.y = -500;
                rightThreeBullet.body.velocity.x = 80;
                rightThreeBullet.outOfBoundsKill = true;
                rightThreeBullet.checkWorldBounds = true;
                this.myplane.lastBulletTime = now;

                var leftThreeBullet = this.myBullets.getFirstExists(false, true, this.myplane.x + 15, this.myplane.y - 7, 'mybullet', false);
                leftThreeBullet.body.velocity.y = -500;
                leftThreeBullet.body.velocity.x = -80;
                leftThreeBullet.outOfBoundsKill = true;
                leftThreeBullet.checkWorldBounds = true;
                this.myplane.lastBulletTime = now;
                }
        }
    }
};

//游戏结束场景
game.MyStates.over = {
    create: function() {
        //背景
        var bg = game.add.tileSprite(0, 0, game.width, game.height, 'background');
        //版权
        this.copyright = game.add.image(12, game.height - 16, 'copyright');
        //我的飞机
        this.myplane = game.add.sprite(100, 100, 'myplane');
        this.myplane.animations.add('fly');
        this.myplane.animations.play('fly', 12, true);
        // 分数
        var style = {font: "bold 32px Arial", fill: "#ff0000", boundsAlignH: "center", boundsAlignV: "middle"};
        this.text = game.add.text(0, 0, "Score: " + score, style);
        this.text.setTextBounds(0, 0, game.width, game.height);
        // 重来按钮
        this.replaybutton = game.add.button(30, 300, 'replaybutton', this.onReplayClick, this, 0, 0, 1);
        // 分享按钮
        this.sharebutton = game.add.button(130, 300, 'sharebutton', this.onShareClick, this, 0, 0, 1);
        // 背景音乐
        this.normalback = game.add.audio('normalback', 0.2, true);
        this.normalback.play();
    },
    onReplayClick: function() {
        this.normalback.stop();
        game.state.start('play');
    },
    onShareClick: function() {

    }
}

//将进度条加载到游戏中
game.state.add('boot', game.MyStates.boot);
//将场景加载到游戏中去
game.state.add('load', game.MyStates.load);
game.state.add('start', game.MyStates.start);
game.state.add('play', game.MyStates.play);
game.state.add('over', game.MyStates.over);
game.state.start('boot');