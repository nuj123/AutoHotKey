/*
    SYNTAX:  find_subset_sum(numbers, target_sum)

        numbers = an array of numbers. ex: [1,2,3,4]
        target_sum = the number that you need to get to. ex: 10

        returns an array containing two keys:
            success: a boolean (true/false) if we found numbers that gives us our target sum.
                - if "True", then there is a match
                - if "False", then there is no match

            subset: the list (csv) of values that added up to our target sum.

        example code:
*/

    ; list of numbers in csv
    numbers := "1,2,3,4,5"

    ; the target of the sum to reach with our possibilities of numbers
    target_sum := 17

    ; convert our number list to array, splitting at the commas
    numbers_array := StrSplit(numbers, ",")

    ; stores the result into "result"
    result := find_subset_sum(numbers_array, target_sum)
    
    ; alternatively, can just straight up do:
    ; result := find_subset_sum([1,2,3,4,5], 10)

    ; if we did indeed find one:
    if (result.success)
    {
        MsgBox, % "A subset of [" numbers "] that adds up to " target_sum " is: " result.subset
    }
    else
    {
        MsgBox, % "No subset of [" numbers "] adds up to " target_sum "."
    }

ExitApp
return


; **********************************
; THE FUNCTION
; **********************************

find_subset_sum(numbers, target_sum)
{
    stack := [{numbers: numbers, target_sum: target_sum, subset: "", depth: 0}]

    while (stack.Length() > 0)
    {
        current := stack.Pop()
        numbers := current.numbers
        target_sum := current.target_sum
        subset := current.subset
        depth := current.depth

        if (depth >= 1000)
        {
            continue
        }
        if (target_sum = 0) ; success!
        {
            ; remove last comma
            subset := SubStr(subset, 1, StrLen(subset) - 1)
            return {success: true, subset: subset}
        }
        else if (target_sum < 0 or numbers.MaxIndex() = 0)
        {
            continue
        }
        else
        {
            first_num := numbers[1]
            rest_of_nums := numbers.Clone()
            rest_of_nums.RemoveAt(1)
            stack.Push({numbers: rest_of_nums, target_sum: target_sum, subset: subset, depth: depth + 1})
            stack.Push({numbers: rest_of_nums, target_sum: target_sum - first_num, subset: subset . first_num . ",", depth: depth + 1})
        }
    }

    return {success: false, subset: ""}
}
