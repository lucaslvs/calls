# Calls

An executable to calculate the total cost of a list of csv file calls.

## Setup

 ### Requiriments
   make sure that you have elixir 1.8 or higher installed in your machine. If you don't have elixir install in your machine, check [elixir documentation](https://elixir-lang.org/install.html) to install.

 ### Compiling the project and genereate executable
  After you configure your machine with elixir, you have to compile the project and generate the executable. to do so, you can run:
  ```sh
  $ mix escript.build
  ```

## Running tests
  To running the application tests you can run in your terminal:
  ```sh
  $ mix test
  ```

## Usage
  To calculate a csv files with all the calls data, you can pass the file path to arguments of the executable. just running:
  ```sh
  ./calls /path/to/file.csv
  ```
