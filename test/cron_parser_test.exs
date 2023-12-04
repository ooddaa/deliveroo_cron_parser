defmodule CronParserTest do
  use ExUnit.Case

  # describe "final" do
  #   test "happy case" do
  #     input = "*/15 0 1,15 * 1-5 /usr/bin/find"
  #
  #     result = """
  #     minute        0 15 30 45
  #     hour          0
  #     day of month  1 15
  #     month         1 2 3 4 5 6 7 8 9 10 11 12
  #     day of week   1 2 3 4 5
  #     command       /usr/bin/find
  #     """
  #   end
  # end

  describe "parsing to ast" do
    # test "first" do 
    #   
    #   input = "* * * * * /usr/bin/find"
    #   CronParser.parse_to_ast(input)
    #   |> IO.inspect()
    #  end

    test "max" do
      input = "* * * * * /usr/bin/find"

      ast = %{
        "minutes" => Enum.map(0..59, &(&1)),
        "hours" => Enum.map(0..23, &(&1)),
        "days" => Enum.map(1..31, &(&1)),
        "months" => Enum.map(1..12, &(&1)),
        "weekdays" => Enum.map(0..6, &(&1)),
        "cmd" => ["/usr/bin/find"]
      }

      result = CronParser.parse_to_ast(input)
      assert result["minutes"] == ast["minutes"]
      assert result == ast
    end

    test "steps" do
      input = "*/15 */6 */5 */3 */2 /usr/bin/find"

      ast = %{
        "minutes" => [0, 15, 30, 45],
        "hours" => [0, 6, 12, 18],
        "days" => [1, 6, 11, 16, 21, 26, 31], 
        "months" => [1, 4, 7, 10],  
        "weekdays" => [0, 2, 4, 6],  
        "cmd" => ["/usr/bin/find"]
      }
      result = CronParser.parse_to_ast(input)
      assert result == ast
    end
   
    test "ranges happy" do
      input = "0-16 12-16 1-10 6-12 0-6 /usr/bin/find"

      ast = %{
        "minutes" => Enum.map(0..16, &(&1)),
        "hours" => Enum.map(12..16, &(&1)),
        "days" => Enum.map(1..10, &(&1)),
        "months" => Enum.map(6..12, &(&1)),
        "weekdays" => [0, 1, 2, 3, 4, 5, 6],  
        "cmd" => ["/usr/bin/find"]
      }
      result = CronParser.parse_to_ast(input)
      assert result == ast
    end
    
    test "multiple ranges happy" do
      input = "0-8,9-16 12-14,15-16 1-5,6-10 6-9,10-12 0-1,4-6 /usr/bin/find"

      ast = %{
        "minutes" => Enum.map(0..16, &(&1)),
        "hours" => Enum.map(12..16, &(&1)),
        "days" => Enum.map(1..10, &(&1)),
        "months" => Enum.map(6..12, &(&1)),
        "weekdays" => [0, 1, 4, 5, 6],  
        "cmd" => ["/usr/bin/find"]
      }

      result = CronParser.parse_to_ast(input)
      assert result == ast
    end
    
    test "selection happy" do
      input = "8,9 14,15 5,6 9,10 1,4 /usr/bin/find"

      ast = %{
        "minutes" => [8,9],
        "hours" => [14,15],
        "days" => [5,6],
        "months" => [9,10],
        "weekdays" => [1, 4],  
        "cmd" => ["/usr/bin/find"]
      }

      result = CronParser.parse_to_ast(input)
      assert result == ast
    end
    
    test "selection one value" do
      input = "0 1 2 3 4 /usr/bin/find"

      ast = %{
        "minutes" => [0],
        "hours" => [1],
        "days" => [2],
        "months" => [3],
        "weekdays" => [4],  
        "cmd" => ["/usr/bin/find"]
      }

      result = CronParser.parse_to_ast(input)
      assert result == ast
    end

    test "final happy case" do
      input = "*/15 0 1,15 * 1-5 /usr/bin/find"

      ast = %{
        "minutes" => [0, 15, 30, 45],
        "hours" => [0],
        "days" => [1,15],
        "months" => Enum.map(1..12, &(&1)),
        "weekdays" => Enum.map(1..5, &(&1)),
        "cmd" => ["/usr/bin/find"]
      }

      result = CronParser.parse_to_ast(input)
      assert result == ast
    end
  end

  test "pretty print" do
    input = "*/15 0 1,15 * 1-5 /usr/bin/find"

    ast = CronParser.parse_to_ast(input)
    CronParser.pretty_print(ast)
    # |> IO.inspect(binaries: :as_strings)
  end
end


