LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.dlx_utils.ALL;
USE ieee.numeric_std.ALL;


ENTITY ALU IS
	GENERIC (N : INTEGER := NbitLong);
	PORT (
		FUNC             : IN ALU_MSG;
		DATA1, DATA2     : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		NEG, ZERO, OVF, CARRY : OUT STD_LOGIC; -- essential status flags for operations
		OUTALU           : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
	);
END ALU;

ARCHITECTURE BEHAVIOR OF ALU IS 

-- PRO VERSION : ALU done with the following components : ADDER, MULTIPLIER, SHIFTER, COMPARATOR .. 
BEGIN
	-- Implementing BASIC version instruction set
	P_ALU : PROCESS (FUNC, DATA1, DATA2)
		VARIABLE TMP : STD_LOGIC_VECTOR(N DOWNTO 0); -- temporary result on N+1 bits
	BEGIN
		TMP := (OTHERS => '0'); -- default values
		CASE FUNC IS
			WHEN R_add  => TMP := STD_LOGIC_VECTOR(SIGNED(DATA1) + SIGNED(DATA2)); -- TO ADD overflow and carry management
			WHEN I_addi => TMP := STD_LOGIC_VECTOR(SIGNED((TO_INTEGER(SIGNED(DATA1)) + TO_INTEGER(UNSIGNED(DATA2))); --immediate is unsigned
			WHEN R_and  => TMP(N - 1 DOWNTO 0) := DATA1 AND DATA2;
			WHEN I_andi => TMP(N - 1 DOWNTO 0) := DATA1 AND DATA2;;
			WHEN I_beqz => IF (SIGNED(DATA1) == X"00000000") THEN --[if (R[rega] == 0) PC <-- PC + imm16]
						    	TMP := STD_LOGIC_VECTOR(SIGNED((TO_INTEGER(SIGNED(DATA1)) + TO_INTEGER(UNSIGNED(DATA2)));
						    END IF;
			WHEN I_bnez => IF (SIGNED(DATA1) /= X"00000000") THEN --[if (R[rega] != 0) PC <-- PC + imm16] 
						    	TMP := STD_LOGIC_VECTOR(SIGNED((TO_INTEGER(SIGNED(DATA1)) + TO_INTEGER(UNSIGNED(DATA2)));
						    END IF;
			WHEN J_j    => ;
			WHEN J_jal  => ;
			WHEN I_lw   => ;
			WHEN I_nop  => TMP := (OTHERS => '0');
			WHEN R_or   => TMP(N - 1 DOWNTO 0) := DATA1 OR DATA2;
			WHEN I_ori  => TMP(N - 1 DOWNTO 0) := DATA1 OR DATA2;
			WHEN R_sge  => IF (SIGNED(DATA1) >= SIGNED(DATA2)) THEN --[if (R[rega] >= R[regb]) R[regc] <-- 1 else R[regc] <-- 0]
								TMP(N-1 DOWNTO 0) := X"0000000" & "0001"; 
						    ELSE 
								TMP(N-1 DOWNTO 0) := X"00000000" ;
							END IF;;
			WHEN I_sgei => ;
			WHEN R_sle  => IF (SIGNED(DATA1) <= SIGNED(DATA2)) THEN --[if (R[rega] <= R[regb]) R[regc] <-- 1 else R[regc] <-- 0]
								TMP(N-1 DOWNTO 0) := X"0000000" & "0001"; 
						    ELSE 
								TMP(N-1 DOWNTO 0) := X"00000000" ;
							END IF;
			WHEN I_slei => ;
			WHEN R_sll  => TMP(N-1 DOWNTO 0) := STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(DATA1),TO_INTEGER(UNSIGNED(DATA2(4 DOWNTO 0)))));
			WHEN I_slli => ;
			WHEN R_sne  => IF (SIGNED(DATA1) /= SIGNED(DATA2)) THEN --[if (R[rega] != R[regb]) R[regc] <-- 1 else R[regc] <-- 0] 
								TMP(N-1 DOWNTO 0) := X"0000000" & "0001"; 
						    ELSE 
								TMP(N-1 DOWNTO 0) := X"00000000" ;
							END IF;
			WHEN I_snei => ;
			WHEN R_srl  => TMP(N-1 DOWNTO 0) := STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(DATA1),TO_INTEGER(UNSIGNED(DATA2(4 DOWNTO 0)))));;
			WHEN I_srli => ;
			WHEN R_sub  => TMP := STD_LOGIC_VECTOR(SIGNED(DATA1) - SIGNED(DATA2)); -- TO ADD overflow and carry management
			WHEN I_subi => TMP := STD_LOGIC_VECTOR(SIGNED((TO_INTEGER(SIGNED(DATA1)) - TO_INTEGER(UNSIGNED(DATA2))); --immediate is unsigned;
			WHEN I_sw   => ;
			WHEN R_xor  => TMP(N - 1 DOWNTO 0) := DATA1 XOR DATA2;
			WHEN I_xori => TMP(N - 1 DOWNTO 0) := DATA1 XOR DATA2;
			WHEN OTHERS => NULL;
		END CASE;
		IF (to_integer(unsigned(TMP(N - 1 DOWNTO 0))) = 0) THEN
			ZERO <= '1'; -- zero flag, discarding additional carry bit
		ELSE
			ZERO <= '0';
		END IF;
		--IF (TMP(N) = '1') THEN
		--	CARRY <= '1'; -- carry active whenever the MSB of the temporary result is set
		--	IF (FUNC = ADD OR FUNC = SUB) THEN
		--		OVF <= '1'; -- overflow flag, only activated by ADD/SUB operations
		--	ELSE
		--		OVF <= '0';
		--	END IF;
		--ELSE
		--	CARRY <= '0';
		--	OVF   <= '0';
		--END IF;
		OUTALU <= TMP(N - 1 DOWNTO 0); -- actual result assignment
	END PROCESS P_ALU;

END BEHAVIOR; 
