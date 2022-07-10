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
		DATA1, DATA2          : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		NEG, ZERO, CARRY, OVF : OUT STD_LOGIC;
		OUTALU                : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
	);
END ALU;

ARCHITECTURE ARITH OF ALU IS
BEGIN
	PROCESS (ALU_OPCODE, DATA1, DATA2)
		VARIABLE TMP : STD_LOGIC_VECTOR(N DOWNTO 0); -- temporary result on (N + 1) bits
	BEGIN
		-- default values
		NEG   <= '0';
		ZERO  <= '0';
		CARRY <= '0';
		OVF   <= '0';
		TMP := (OTHERS => '0');

		CASE ALU_OPCODE IS
			WHEN I_addui | I_jr | I_jalr | I_lbu | I_lhu | R_addu =>
				TMP := STD_LOGIC_VECTOR(UNSIGNED('0' & DATA1) + UNSIGNED('0' & DATA2));
				OVF <= TMP(N);
			WHEN J_j | J_jal | I_addi | I_lb | I_lh | I_lw | I_sb | I_sh | I_sw | R_add =>
				TMP := STD_LOGIC_VECTOR(SIGNED('0' & DATA1) + SIGNED('0' & DATA2));
				NEG <= TMP(N - 1);
				OVF <= (DATA1(N - 1) AND DATA2(N - 1) AND NOT TMP(N - 1)) OR (NOT DATA1(N - 1) AND NOT DATA2(N - 1) AND TMP(N - 1));
			WHEN I_beqz              =>
				IF (DATA2 = (DATA2'RANGE => '0')) THEN
					TMP := STD_LOGIC_VECTOR(SIGNED('0' & DATA1) + SIGNED('0' & DATA2));
					NEG <= TMP(N - 1);
					OVF <= (DATA1(N - 1) AND DATA2(N - 1) AND NOT TMP(N - 1)) OR (NOT DATA1(N - 1) AND NOT DATA2(N - 1) AND TMP(N - 1));
				END IF;
			WHEN I_bnez               =>
				IF (DATA2 /= (DATA2'RANGE => '0')) THEN
					TMP := STD_LOGIC_VECTOR('0' & SIGNED(DATA1) + SIGNED('0' & DATA2));
					NEG <= TMP(N - 1);
					OVF <= (DATA1(N - 1) AND DATA2(N - 1) AND NOT TMP(N - 1)) OR (NOT DATA1(N - 1) AND NOT DATA2(N - 1) AND TMP(N - 1));
				END IF;
			WHEN I_subui | R_subu =>
				TMP := STD_LOGIC_VECTOR(UNSIGNED('0' & DATA1) - UNSIGNED('0' & DATA2));
				OVF <= TMP(N);
			WHEN I_subi | R_sub =>
				TMP := STD_LOGIC_VECTOR(SIGNED('0' & DATA1) - SIGNED('0' & DATA2));
				NEG <= TMP(N - 1);
				OVF <= (DATA1(N - 1) AND DATA2(N - 1) AND NOT TMP(N - 1)) OR (NOT DATA1(N - 1) AND NOT DATA2(N - 1) AND TMP(N - 1));
			WHEN I_andi | R_and =>
				TMP := ('0' & DATA1) AND ('0' & DATA2);
			WHEN I_ori | R_or =>
				TMP := ('0' & DATA1) OR ('0' & DATA2);
			WHEN I_xori | R_xor =>
				TMP := ('0' & DATA1) XOR ('0' & DATA2);
			WHEN I_lhi =>
				TMP := STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED('0' & DATA2), N / 2));
			WHEN I_slli | R_sll =>
				TMP := STD_LOGIC_VECTOR(SHIFT_LEFT(UNSIGNED('0' & DATA1), TO_INTEGER(UNSIGNED(DATA2(4 DOWNTO 0)))));
			WHEN I_srli | R_srl =>
				TMP := STD_LOGIC_VECTOR(SHIFT_RIGHT(UNSIGNED(DATA1 & '0'), TO_INTEGER(UNSIGNED(DATA2(4 DOWNTO 0)))));
			WHEN I_srai | R_sra =>
				TMP := STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(DATA1 & '0'), TO_INTEGER(UNSIGNED(DATA2))));
				NEG <= TMP(N - 1);
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
			WHEN R_mult =>
				TMP(N - 1 DOWNTO 0) := STD_LOGIC_VECTOR(SIGNED(DATA1((N / 2) - 1 DOWNTO 0)) * SIGNED(DATA2((N / 2) - 1 DOWNTO 0)));
				NEG <= TMP(N - 1);
			WHEN R_multu =>
				TMP(N - 1 DOWNTO 0) := STD_LOGIC_VECTOR(UNSIGNED(DATA1((N / 2) - 1 DOWNTO 0)) * UNSIGNED(DATA2((N / 2) - 1 DOWNTO 0)));
			WHEN OTHERS => -- faults + NOPs
				NULL;
		END CASE;

		IF (ALU_OPCODE = I_srli OR ALU_OPCODE = R_srl OR ALU_OPCODE = I_srai OR ALU_OPCODE = R_sra) THEN
			CARRY  <= TMP(0); -- carry @ LSB
			OUTALU <= TMP(N DOWNTO 1);
			IF (TMP(N DOWNTO 1) = (N DOWNTO 1 => '0')) THEN
				ZERO <= '1'; -- zero result @ N..1
			END IF;
		ELSE              -- normal
			CARRY  <= TMP(N); -- carry @ MSB
			OUTALU <= TMP(N - 1 DOWNTO 0);
			IF (TMP(N - 1 DOWNTO 0) = (N - 1 DOWNTO 0 => '0')) THEN
				ZERO <= '1'; -- zero result @ N-1..0
			END IF;
		END IF;
	END PROCESS;
END ARITH;