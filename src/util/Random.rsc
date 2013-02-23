module util::Random

import String;
import util::Math;

public real seed(int val) =
  arbSeed(val);

public real random() =
  arbReal();

public real random(num max) =
  arbReal() * toReal(max);

public real random(num min, num max) =
  toReal(min) + arbReal() * (toReal(max) - toReal(min));

public int randInt() =
  arbInt();

public int randInt(int max) =
  arbInt(max + 1);

public int randInt(int min, int max) =
  min + arbInt(max - min + 1);

public bool randBool() =
  arbInt(2) == 0;

public list[int] randListInt() =
  [randInt() | i <- [0 .. randInt(255)]];

public list[int] randListInt(int n) =
  [randInt() | i <- [1 .. n]];

public list[int] randListInt(int n, int max) =
  [randInt(max) | i <- [1 .. n]];

public list[int] randListInt(int n, int min, int max) =
  [randInt(min, max) | i <- [1 .. n]];

public str randStr() =
  stringChars(randListInt(randInt(255), 32, 126));

public str randStr(int n) =
  stringChars(randListInt(n, 32, 126));
