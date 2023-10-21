import 'dart:async';
import 'dart:core';

import 'package:cool_alert/cool_alert.dart';
import 'package:flappy_bird/barrier.dart';
import 'package:flappy_bird/bird.dart';
import 'package:flappy_bird/coverScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String HIGH_SCORE_KEY = 'highScore';
  static double birdY = 0;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -9.8;
  double velocity = 2;
  double birdWidth = 0.1;
  double birdHeight = 0.1;

  int score = 0;
  int highScore = 0;
  late Timer scoreTimer;

  bool isGameStarted = false;
  static List<double> barrierX = [1, 1 + 1.75];
  static double barrierWidth = 0.25;
  List<List<double>> barrierHeight = [
    [0.8, 0.2],
    [0.7, 0.3],
    [0.6, 0.4],
    [0.3, 0.7],
    [0.2, 0.8],
    [0.4, 0.6],
    [0.5, 0.5],
  ];

  Future<void> getHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt(HIGH_SCORE_KEY) ?? 0;
    });
  }

  void setValues() {
    setState(() {
      birdY = 0;
      time = 0;
      height = 0;
      initialPos = birdY;
      barrierX[0] = 1;
      barrierX[1] = barrierX[0] + 1.75;
      score = 0;
    });
  }

  void startGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isGameStarted = true;
    scoreTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (isGameStarted) {
          setState(() {
            score++;
          });
        }
      },
    );
    Timer.periodic(const Duration(milliseconds: 30), (timer) async {
      height = (0.5 * gravity * time * time) + (velocity * time);

      setState(() {
        birdY =
            initialPos - height; //birdY when negative means bird goes higher
      });

      if (isBirdDead()) {
        timer.cancel();
        if (score > highScore) {
          highScore = score;
          await prefs.setInt(HIGH_SCORE_KEY, highScore);
        }
        setState(() {
          isGameStarted = false;
        });
        _showDialog();
      }

      moveMap();

      time += 0.01;
    });
  }

  void jump() {
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  void moveMap() {
    for (int i = 0; i < barrierX.length; i++) {
      setState(() {
        barrierX[i] -= 0.005;
      });

      if (barrierX[i] < -1.5) {
        barrierX[i] += 3;
      }
    }
  }

  bool isBirdDead() {
    if (birdY < -1 || birdY > 1) {
      return true;
    }

    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierWidth >= -birdWidth &&
          (birdY <= -1 + barrierHeight[i][0] ||
              birdY + birdHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }
    return false;
  }

  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.brown,
            title: Center(
                child: Column(
              children: [
                const Text(
                  "G A M E  O V E R",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  score <= 0
                      ? "Hard Luck"
                      : "Great! you got $score points!",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            )),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        "Play Again",
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  Future<void> showLoseDialog() async {
    await CoolAlert.show(
      context: context,
      type: CoolAlertType.info,
      title: 'G A M E  O V E R',
      text: score <= 0 ? 'Hard Luck 😂' : 'Great! you got $score points! 🤩',
      confirmBtnText: 'Retry',
      cancelBtnText: 'Exit',
      confirmBtnColor: Colors.cyan,
      cancelBtnTextStyle: TextStyle(
        color: Colors.red[900],
      ),
      showCancelBtn: true,
      barrierDismissible: false,
      animType: CoolAlertAnimType.rotate,
      backgroundColor: Colors.lightBlueAccent,
      onConfirmBtnTap: () {
        // Navigator.of(context).pop();
        // setValues();
        resetGame();
      },
      onCancelBtnTap: () {
        // Navigator.of(context).pop();
        // Navigator.of(context).pop();
      },
    );
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      birdY = 0;
      isGameStarted = false;
      time = 0;
      barrierX = [1, 1 + 1.75];
      initialPos = birdY;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setValues();
    getHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isGameStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                  color: const Color(0xff6FC3CD),
                  child: Center(
                    child: Stack(
                      children: [
                        MyBird(
                            birdY: birdY,
                            birdWidth: birdWidth,
                            birdHeight: birdHeight),
                        //CoverScreen(isGameStarted: isGameStarted),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[0][0],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[0][1],
                            isTheBottomBarrier: true),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[1][0],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[1][1],
                            isTheBottomBarrier: true),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[2][0],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[2][1],
                            isTheBottomBarrier: true),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[3][0],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[3][1],
                            isTheBottomBarrier: true),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[4][0],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[4][1],
                            isTheBottomBarrier: true),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[5][0],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[5][1],
                            isTheBottomBarrier: true),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[6][0],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[0],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[6][1],
                            isTheBottomBarrier: true),
                        Container(
                          alignment: const Alignment(0, -0.5),
                          child: Text(
                            isGameStarted ? "" : "T A P  T O  P L A Y",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            Expanded(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.brown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("S C O R E",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                            Text(
                              "$score",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text("H I G H  S C O R E",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                            Text(
                              "$highScore",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}
