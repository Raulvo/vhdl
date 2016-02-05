library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.std_logic_misc.all;

package functions_and_types is

    type array_1d_logic is array (natural range <>) of std_logic;
    type array_1d_logic_vector is array (natural range <>) of std_logic_vector;
    type array_2d_logic is array (natural range <>, natural range <>) of std_logic;
    type array_2d_logic_vector is array (natural range <>, natural range <>) of std_logic_vector;
    
    function or_reduce_2d_logic(a : array_2d_logic; i : integer) return std_logic;
    function or_reduce_2d_logic_vector(a : array_2d_logic_vector; i : integer) return std_logic_vector;
    
    function bitwise_cmp(a : std_logic_vector; b : std_logic_vector) return std_logic;
    function bitwise_cmp(a : std_logic; b : std_logic) return std_logic;
    
    function full_adder(a : std_logic_vector; b : std_logic_vector; ci : std_logic) return std_logic_vector;
    
    function sign_extend(a : std_logic_vector; b : integer) return std_logic_vector;
    function sign_extend(a : std_logic; b : integer) return std_logic_vector;
    function logic_extend(a : std_logic_vector; b : integer) return std_logic_vector;
    function logic_extend(a : std_logic; b : integer) return std_logic_vector;
end functions_and_types;

package body functions_and_types is
/* OR_REDUCE_2D_LOGIC */
    function or_reduce_2d_logic(a : array_2d_logic; i : integer) return std_logic is
        variable reduced : std_logic := '0';
    begin
        -- Variable is updated without time advancing. Time advances when process deactivates. Signals are updated then.
        -- Thus, for an instant "t", we obtain the reduction of the array.
        -- To make that possible, synthesis must do an "or" with width a'length
        -- If we did this with signals, each iteration of the loop would represent 
        -- a diferent instant in time, as the same signal is being updated to itself,
        -- for doing that, the signal must be updated, and that only occurs in different 
        -- instants "t" of time, so signal never stabilizes or a "buffer" is generated in order 
        -- to do the feedback between each iteration and leave the last assignment applied.
        for j in 0 to a'length(2)-1 loop
            reduced := reduced or a(i,j);
        end loop;

        return reduced;
    end function or_reduce_2d_logic;
    /* OR_REDUCE_2D_LOGIC_VECTOR */
    function or_reduce_2d_logic_vector(a : array_2d_logic_vector; i : integer) return std_logic_vector is
        variable reduced : std_logic_vector(a'left(2) downto 0) := (others => '0');
    begin
        for j in 0 to a'length(2)-1 loop
            reduced := reduced or a(i,j);
        end loop;

        return reduced;
    end function or_reduce_2d_logic_vector;
    
    function sign_extend(a : std_logic_vector; b : integer) return std_logic_vector is
    begin
        return std_logic_vector(resize(signed(a),b));
    end function sign_extend;
    
    function sign_extend(a : std_logic; b : integer) return std_logic_vector is
        variable extended : std_logic_vector(b-1 downto 0);
    begin
        for i in 0 to extended'left loop
            extended(i) := a;
        end loop;
        return extended;
    end function sign_extend;
    
    function logic_extend(a : std_logic_vector; b : integer) return std_logic_vector is
    begin
        return std_logic_vector(resize(unsigned(a),b));
    end function logic_extend;
    
    function logic_extend(a : std_logic; b : integer) return std_logic_vector is
        variable extended : std_logic_vector(b-1 downto 0);
    begin
        for i in 0 to extended'left loop
            extended(i) := a;
        end loop;
        return extended;
    end function logic_extend;
    
    
    /* FULL ADDER */
    /* This circuit is based on a carry look-ahead adder */
    function full_adder(a : std_logic_vector; b : std_logic_vector; ci : std_logic) return std_logic_vector is
        variable result : std_logic_vector(a'left+1 downto a'right) := sign_extend('0', a'length+1);
        variable coi : std_logic_vector(a'left+1 downto a'right) := sign_extend('0', a'length+1);
        variable or_l1 : std_logic_vector(a'left+1 downto a'right) := sign_extend('0', a'length+1);
        variable and_l1 : std_logic_vector(a'left+1 downto a'right) := sign_extend('0', a'length+1);
        variable or_l3 : std_logic_vector(a'left+1 downto a'right) := sign_extend('0', a'length+1);
        variable and_l2 : array_2d_logic(a'length downto 0,a'length downto 0);
        variable aa : std_logic_vector(a'left+1 downto a'right) := sign_extend(a, a'length+1);
        variable bb : std_logic_vector(b'left+1 downto b'right) := sign_extend(b, b'length+1);
    begin
        /* Initialize intermediate results */
        aa := sign_extend(a,aa'length);
        bb := sign_extend(b,bb'length);
        for i in coi'left downto coi'right loop
            coi(i) := '0';
            or_l1(i) := aa(i) or bb(i);
            and_l1(i) := aa(i) and bb(i);
            for j in and_l2'left(1) downto 1 loop
                and_l2(i,j) := '1';
            end loop;
        end loop;
        
        for i in and_l2'left downto 1 loop
            and_l2(i,0) := and_l1(i-1);
        end loop;
        coi(0) := ci;
        
        /* Compute carry outs */
        
        /* First term : all coi */
        for i in coi'left downto coi'right+1 loop
            coi(i) := coi(i) or and_l2(i,0);
        end loop;
        
        /* Middle terms: From coi(n) downto coi(2) */
        for i in coi'left downto coi'right+2 loop
            for j in i-1 downto coi'right+1 loop
                for k in i-1 downto i-j loop
                    and_l2(i,j) := and_l2(i,j) and or_l1(k);
                end loop;
                and_l2(i,j) := and_l2(i,j) and and_l1(i-j);
                coi(i) := coi(i) or and_l2(i,j);
            end loop;
        end loop;
        
        /* Last term : all coi */
        for i in coi'left downto coi'right+1 loop
            for k in i-1 downto 0 loop
                and_l2(i,i) := and_l2(i,i) and or_l1(k);
            end loop;
            and_l2(i,i) := and_l2(i,i) and ci;
            coi(i) := coi(i) or and_l2(i,i);
        end loop;
        
        /* Add bits */
        result(result'left) := coi(coi'left-1);
        for i in result'left-1 downto 1 loop
            result(i) := coi(i) xor aa(i) xor bb(i);
        end loop;
        result(0) := ci xor aa(0) xor bb(0);
        return result;
    end;
    
    /* BIT WISE COMPARATOR */
    function bitwise_cmp(a : std_logic_vector; b : std_logic_vector) return std_logic is
    begin
        return and_reduce(not(a xor b));
    end;
    
    function bitwise_cmp(a : std_logic; b : std_logic) return std_logic is
    begin
        return not(a xor b);
    end;
end functions_and_types;
