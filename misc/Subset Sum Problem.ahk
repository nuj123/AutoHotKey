#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

; The list of numbers to add
numbers := [1,2,3,4,5]

; The target to add to. 
target_sum := 9

; numbers_array := StrSplit(numbers, ",")
result := find_subset_sum(numbers, target_sum)

if (found_subset)
{
    MsgBox, % "The subset that adds up to " target_sum " is: " result.subset
}
else
{
    MsgBox, % "No subset adds up to " target_sum "."
}
return


find_subset_sum(numbers, target_sum)
{
    global found_subset
    max_depth := 1000
    stack := [{numbers: numbers, target_sum: target_sum, subset: "", depth: 0}]

    while (stack.Length() > 0)
    {
        current := stack.Pop()
        numbers := current.numbers
        target_sum := current.target_sum
        subset := current.subset
        depth := current.depth

        if (depth >= max_depth)
        {
            continue
        }
        if (target_sum = 0)
        {
            found_subset := true
            return {subset: subset}
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

    return {subset: ""}
}
