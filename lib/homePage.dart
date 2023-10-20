import 'dart:async';
import 'dart:core';

import 'package:flappy_bird/barrier.dart';
import 'package:flappy_bird/bird.dart';
import 'package:flappy_bird/coverScreen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double birdY = 0;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -9.8;
  double velocity = 3;
  double birdWidth = 0.1;
  double birdHeight = 0.1;

  bool isGameStarted = false;
  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierWidth = 0.5;
  List<List<double>> barrierHeight = [
    [0.6, 0.4],
    [0.4, 0.6],
  ];

  void startGame() {
    isGameStarted = true;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      height = (gravity * time * time) + (velocity * time);

      setState(() {
        birdY =
            initialPos - height; //birdY when negative means bird goes higher
      });

      if (isBirdDead()) {
        timer.cancel();
        isGameStarted = false;
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
            title: const Center(
              child: Text(
                "G A M E  O V E R",
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    color: Colors.white,
                    child: const Text(
                      "Play Again",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              )
            ],
          );
        });
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      birdY = 0;
      isGameStarted = false;
      time = 0;
      initialPos = birdY;
    });
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
                  color: Colors.blueAccent,
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
                            barrierHeight: barrierHeight[1][0],
                            isTheBottomBarrier: true),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[1][1],
                            isTheBottomBarrier: false),
                        Barrier(
                            barrierX: barrierX[1],
                            barrierWidth: barrierWidth,
                            barrierHeight: barrierHeight[0][1],
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
              color: Colors.brown,
            )),
          ],
        ),
      ),
    );
  }
}
