# Baby-Step Giant-Step Discrete Logarithm Finder

# find 𝑥 where 𝛼^𝑥 ≡ 𝛽 mod 𝑛

def find_greatest_common_divisor(a, b)
    a, b = b, a % b while b != 0
    
    return a
end

def find_whole_number_square_root(square)
    raise ArgumentError, "Square should not be less than zero." if square < 0
    
    return square if square < 2
    
    lower_bound = 1
    upper_bound = square / 2
    
    while lower_bound < upper_bound + 1
        midpoint = (lower_bound + upper_bound) / 2
        midpoint_squared = midpoint * midpoint
        
        if midpoint_squared == square
            return midpoint
        elsif midpoint_squared < square
            lower_bound = midpoint + 1
        else
            upper_bound = midpoint - 1
        end
    end
    
    return upper_bound
end

def exponentiate_modularly(base, exponent, modulus)
    return 0 if base == 0 || modulus == 1 
    return 1 if exponent == 0
        
    base %= modulus
    
    power = 1
    
    while exponent > 0
        power = (power * base) % modulus if exponent & 1 == 1
        
        base = (base * base) % modulus
        exponent >>= 1
    end
    
    return power
end

def find_modular_multiplicative_inverse(base, modulus)
    return 0 if modulus == 1
    return nil if modulus < 1 || base == 0
    
    base %= modulus
    
    last_remainder, remainder = base, modulus
    last_modular_multiplicative_inverse_of_base, modular_multiplicative_inverse_of_base = 1, 0
    
    while remainder != 0
        quotient = last_remainder / remainder
        
        saved_remainder = remainder
        remainder = last_remainder - quotient * remainder
        last_remainder = saved_remainder
        
        saved_modular_multiplicative_inverse_of_base = modular_multiplicative_inverse_of_base
        modular_multiplicative_inverse_of_base = last_modular_multiplicative_inverse_of_base - quotient * modular_multiplicative_inverse_of_base
        last_modular_multiplicative_inverse_of_base = saved_modular_multiplicative_inverse_of_base
    end
    
    return nil if last_remainder != 1
    
    return last_modular_multiplicative_inverse_of_base % modulus
end

def find_exponential_index(alpha, beta, modulus)
    raise ArgumentError, "modulus #{modulus} must be greater than or equal to two (2)." if modulus < 2
    # raise ArgumentError, "modulus #{modulus} must be prime." unless modulus.prime?
    raise ArgumentError, "alpha #{alpha} not invertible mod #{modulus}." unless find_greatest_common_divisor(alpha, modulus) == 1
    raise ArgumentError, "beta #{beta} lies outside the multiplicative group mod #{modulus}." unless find_greatest_common_divisor(beta, modulus) == 1
    
    # trivial cases
    return 0 if beta % modulus == 1
    return nil if alpha % modulus == 0 && beta % modulus != 0
    return 1 if alpha % modulus == 0 && beta % modulus == 0
    return nil if alpha % modulus == 1
    
    # only if modulus is prime
    group_order = modulus - 1
    
    # raise ArgumentError, "beta #{beta} lies outside the group of order #{group_order}." unless exponentiate_modularly(beta, group_order, modulus) == 1
    
    square_root = find_whole_number_square_root(group_order)
    square_root_of_group_order_upper_step_bound = square_root * square_root == (group_order) ? square_root : square_root + 1
    
    baby_steps = {}
    
    index = 1
    
    # baby steps
    
    for baby_step in 0...square_root_of_group_order_upper_step_bound
        baby_steps[index] = baby_step
        
        index = (index * alpha) % modulus
    end
    
    modular_multiplicative_inverse_of_alpha = find_modular_multiplicative_inverse(alpha, modulus)
    
    return nil unless modular_multiplicative_inverse_of_alpha
    
    modular_multiplicative_inverse_of_square_root_of_group_order_upper_step_bounded_power_of_alpha = exponentiate_modularly(modular_multiplicative_inverse_of_alpha, square_root_of_group_order_upper_step_bound, modulus)
    
    gamma = beta % modulus
    
    # giant steps
    
    for giant_step in 0...square_root_of_group_order_upper_step_bound
        if baby_steps.key?(gamma)
            return (giant_step * square_root_of_group_order_upper_step_bound + baby_steps[gamma]) % (group_order)
        end
        
        gamma = (gamma * modular_multiplicative_inverse_of_square_root_of_group_order_upper_step_bounded_power_of_alpha) % modulus
    end
    
    return nil
end

print "Enter base: "
alpha = gets.chomp.to_i

print "Enter modular power: "
beta = gets.chomp.to_i

print "Enter modulus: "
modulus = gets.chomp.to_i

exponential_index = find_exponential_index(alpha, beta, modulus)

puts

print "#{exponential_index} is the exponential index (discrete logarithm) of #{beta} in base #{alpha} mod #{modulus}."
