# Centipede
Final project for CSC258: Computer Architecture
<br/><br/>
Coded in MIPS architecture
<br/><br/>
Based of the classic Atari arcade game [Centipede®](https://en.wikipedia.org/wiki/Centipede_(video_game))
![image](https://user-images.githubusercontent.com/53841219/119232864-afd9b880-baf4-11eb-8bf2-c278505dca2f.png)

![image](https://user-images.githubusercontent.com/53841219/119233565-c1708f80-baf7-11eb-84dc-3e4cc66957c4.png)


## Rules
Use your Bug Blaster (blue square) and shoot the 10-piece centipede before it wriggles to the end of the board. Avoid fleas (magenta square) and shoot mushrooms (orange square) so the centipede has less obstacles to hide behind. Beware, you only have 1 life!

## Controls
* x - Shoot bullet (only 1 on screen at a time)
* j - Move Bug Blaster left
* k - Move Bug Blaster right
* r - Replay game (at "BYE" screen)

## Configuration
Bitmap Display Configuration: 
*  Unit width in pixels: 8  
*  Unit height in pixels: 8
*  Display width in pixels: 256
*  Display height in pixels: 256
*  Base Address for Display: 0x10008000 ($gp)
