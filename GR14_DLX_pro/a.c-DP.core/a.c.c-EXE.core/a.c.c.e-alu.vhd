LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.dlx_utils.ALL;

ENTITY ALU IS
	GENERIC
		(N : INTEGER := NbitLong);
	PORT
	(
		ALU_OPCODE            : IN ALU_MSG;
		DATA1, DATA2          : IN STD_LOGIC_VECTOR(0 TO N - 1);
		NEG, ZERO, OVF, CARRY : OUT STD_LOGIC;
		OUTALU                : OUT STD_LOGIC_VECTOR(0 TO N - 1)
	);
END ALU;

ARCHITECTURE ARITH OF ALU IS
BEGIN
	PROCESS (ALU_OPCODE, DATA1, DATA2)
		VARIABLE TMP : STD_LOGIC_VECTOR(0 TO N); -- temporary result on N + 1 bits
	BEGIN
		TMP := (OTHERS => '0'); -- default value
		CASE ALU_OPCODE IS
			WHEN I_addui | I_jr | I_jalr | I_lbu | I_lhu | R_addu =>
				TMP := STD_LOGIC_VECTOR(UNSIGNED(DATA1) + UNSIGNED(DATA2));
			WHEN J_j | J_jal | I_addi | I_lb | I_lh | I_lw | I_sb | I_sh | I_sw | R_add =>
				TMP := STD_LOGIC_VECTOR(SIGNED(DATA1) + SIGNED(DATA2));
			WHEN I_beqz              =>
				IF (DATA2 = (DATA2'RANGE => '0')) THEN
					TMP := STD_LOGIC_VECTOR(SIGNED(DATA1) + SIGNED(DATA2));
				END IF;
			WHEN I_bnez               =>
				IF (DATA2 /= (DATA2'RANGE => '0')) THEN
					TMP := STD_LOGIC_VECTOR(SIGNED(DATA1) + SIGNED(DATA2));
				END IF;
			WHEN I_subui | R_subu =>
				TMP := STD_LOGIC_VECTOR(UNSIGNED(DATA1) - UNSIGNED(DATA2));
			WHEN I_subi | R_sub =>
				TMP := STD_LOGIC_VECTOR(SIGNED(DATA1) - SIGNED(DATA2));
			WHEN I_andi | R_and =>
				TMP(0 TO N - 1) := DATA1 AND DATA2;
			WHEN I_ori | R_or =>
				TMP(0 TO N - 1) := DATA1 OR DATA2;
			WHEN I_xori | R_xor =>
				TMP(0 TO N - 1) := DATA1 XOR DATA2;
			WHEN I_lhi =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(DATA1), NbitShort));
			WHEN I_slli | R_sll =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED(DATA1), TO_INTEGER(UNSIGNED(DATA2(27 TO 31)))));
			WHEN I_srli | R_srl =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(DATA1), TO_INTEGER(UNSIGNED(DATA2(27 TO 31)))));
			WHEN I_srai | R_sra =>
				TMP(0 TO N - 1) := STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(DATA1), TO_INTEGER(UNSIGNED(DATA2)));
			WHEN I_seqi | R_seq =>
				IF (SIGNED(DATA1) = SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_snei | R_sne =>
				IF (SIGNED(DATA1) /= SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_slti | R_slt =>
				IF (SIGNED(DATA1) < SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_sgti | R_sgt =>
				IF (SIGNED(DATA1) > SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_slei | R_sle =>
				IF (SIGNED(DATA1) <= SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_sgei | R_sge =>
				IF (SIGNED(DATA1) >= SIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_sltui | R_sltu =>
				IF (UNSIGNED(DATA1) < UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_sgtui | R_sgtu =>
				IF (UNSIGNED(DATA1) > UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_sleui | R_sleu =>
				IF (UNSIGNED(DATA1) <= UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
			WHEN I_sgeui | R_sgeu =>
				IF (UNSIGNED(DATA1) >= UNSIGNED(DATA2)) THEN
					TMP(0) := '1';
				END IF;
				-- MULTIPLICATIONS ?!
			WHEN OTHERS => NULL; -- faults + NOP
		END CASE;
		IF (TMP = (TMP'RANGE => '0')) THEN
			ZERO <= '1';
		ELSE
			ZERO <= '0';
		END IF;
		-- Reminder: CPSR FLAGS management.
		OUTALU <= TMP(N - 1 DOWNTO 0); -- actual result assignment
	END PROCESS;
END ARITH;