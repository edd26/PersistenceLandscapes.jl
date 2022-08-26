import Base.:<, Base.:>, Base.==, Base.isless

# tested
struct MyPair
    first::Float64
    second::Float64
end

# based on compareMyPairs function
function isless(p1::MyPair, p2::MyPair)
    return <(p1, p2)
end

function <(p1::MyPair, p2::MyPair)
    if p1.first<p2.first
        return true
    elseif p1.first == p2.first
        if p1.second < p2.second
            return true
        end
    else
        return false
    end
end

function >(p1::MyPair, p2::MyPair)
    if p1.first>p2.first
        return true
    elseif p1.first == p2.first
        if p1.second > p2.second
            return true
        end
    else
        return false
    end
end


function ==(p1::MyPair, p2::MyPair)
    return p1.first == p2.first && p1.second == p2.second
end

# tested
function make_MyPair(val1, val2)
    return MyPair(val1, val2)
end
