# Test Excution for Competitive programming

This program test your code by multiple test cases.
Assuming online programming judgement site, AtCoder, AIZU ONLINE JUDGE, and so on.
Currently, supporting for C++14.

## Dependency

Ruby
g++

## Setup

Clone this repository and copy test cases from online site and paste to testcase.yml.
And write your code in main.cpp.
After your writing, execute below command and then you'll see colored test result.

```
$ ruby run.rb -l c++14 -s sample/main.cpp -t sample/testcase.yml
```

<img src="https://raw.githubusercontent.com/sh1nduu/CompetitiveProgrammingTester/master/misc/command.png " height="150">

## Licence

This software is released under the MIT License, see LICENSE.
