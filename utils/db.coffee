# Since I don't have a config file atm, lets just wrap it in a function.
# Also, I want to use promises, so I'll wrap the query method.
pg = require('pg')
#Q = require('q')
Promise = require('bluebird')

# Auto-generated. Debugging is terrible with this driver.
# Source:
# http://www.postgresql.org/docs/current/static/errcodes-appendix.html
errorCodes =
  "00000":{"name":"successful_completion","class":"00 — Successful Completion"}
  "01000":{"name":"warning","class":"01 — Warning"}
  "0100C":{"name":"dynamic_result_sets_returned","class":"01 — Warning"}
  "01008":{"name":"implicit_zero_bit_padding","class":"01 — Warning"}
  "01003":{"name":"null_value_eliminated_in_set_function","class":"01 — Warning"}
  "01007":{"name":"privilege_not_granted","class":"01 — Warning"}
  "01006":{"name":"privilege_not_revoked","class":"01 — Warning"}
  "01004":{"name":"string_data_right_truncation","class":"01 — Warning"}
  "01P01":{"name":"deprecated_feature","class":"01 — Warning"}
  "02000":{"name":"no_data","class":"02 — No Data (this is also a warning class per the SQL standard)"}
  "02001":{"name":"no_additional_dynamic_result_sets_returned","class":"02 — No Data (this is also a warning class per the SQL standard)"}
  "03000":{"name":"sql_statement_not_yet_complete","class":"03 — SQL Statement Not Yet Complete"}
  "08000":{"name":"connection_exception","class":"08 — Connection Exception"}
  "08003":{"name":"connection_does_not_exist","class":"08 — Connection Exception"}
  "08006":{"name":"connection_failure","class":"08 — Connection Exception"}
  "08001":{"name":"sqlclient_unable_to_establish_sqlconnection","class":"08 — Connection Exception"}
  "08004":{"name":"sqlserver_rejected_establishment_of_sqlconnection","class":"08 — Connection Exception"}
  "08007":{"name":"transaction_resolution_unknown","class":"08 — Connection Exception"}
  "08P01":{"name":"protocol_violation","class":"08 — Connection Exception"}
  "09000":{"name":"triggered_action_exception","class":"09 — Triggered Action Exception"}
  "0A000":{"name":"feature_not_supported","class":"0A — Feature Not Supported"}
  "0B000":{"name":"invalid_transaction_initiation","class":"0B — Invalid Transaction Initiation"}
  "0F000":{"name":"locator_exception","class":"0F — Locator Exception"}
  "0F001":{"name":"invalid_locator_specification","class":"0F — Locator Exception"}
  "0L000":{"name":"invalid_grantor","class":"0L — Invalid Grantor"}
  "0LP01":{"name":"invalid_grant_operation","class":"0L — Invalid Grantor"}
  "0P000":{"name":"invalid_role_specification","class":"0P — Invalid Role Specification"}
  "0Z000":{"name":"diagnostics_exception","class":"0Z — Diagnostics Exception"}
  "0Z002":{"name":"stacked_diagnostics_accessed_without_active_handler","class":"0Z — Diagnostics Exception"}
  "20000":{"name":"case_not_found","class":"20 — Case Not Found"}
  "21000":{"name":"cardinality_violation","class":"21 — Cardinality Violation"}
  "22000":{"name":"data_exception","class":"22 — Data Exception"}
  "2202E":{"name":"array_subscript_error","class":"22 — Data Exception"}
  "22021":{"name":"character_not_in_repertoire","class":"22 — Data Exception"}
  "22008":{"name":"datetime_field_overflow","class":"22 — Data Exception"}
  "22012":{"name":"division_by_zero","class":"22 — Data Exception"}
  "22005":{"name":"error_in_assignment","class":"22 — Data Exception"}
  "2200B":{"name":"escape_character_conflict","class":"22 — Data Exception"}
  "22022":{"name":"indicator_overflow","class":"22 — Data Exception"}
  "22015":{"name":"interval_field_overflow","class":"22 — Data Exception"}
  "2201E":{"name":"invalid_argument_for_logarithm","class":"22 — Data Exception"}
  "22014":{"name":"invalid_argument_for_ntile_function","class":"22 — Data Exception"}
  "22016":{"name":"invalid_argument_for_nth_value_function","class":"22 — Data Exception"}
  "2201F":{"name":"invalid_argument_for_power_function","class":"22 — Data Exception"}
  "2201G":{"name":"invalid_argument_for_width_bucket_function","class":"22 — Data Exception"}
  "22018":{"name":"invalid_character_value_for_cast","class":"22 — Data Exception"}
  "22007":{"name":"invalid_datetime_format","class":"22 — Data Exception"}
  "22019":{"name":"invalid_escape_character","class":"22 — Data Exception"}
  "2200D":{"name":"invalid_escape_octet","class":"22 — Data Exception"}
  "22025":{"name":"invalid_escape_sequence","class":"22 — Data Exception"}
  "22P06":{"name":"nonstandard_use_of_escape_character","class":"22 — Data Exception"}
  "22010":{"name":"invalid_indicator_parameter_value","class":"22 — Data Exception"}
  "22023":{"name":"invalid_parameter_value","class":"22 — Data Exception"}
  "2201B":{"name":"invalid_regular_expression","class":"22 — Data Exception"}
  "2201W":{"name":"invalid_row_count_in_limit_clause","class":"22 — Data Exception"}
  "2201X":{"name":"invalid_row_count_in_result_offset_clause","class":"22 — Data Exception"}
  "22009":{"name":"invalid_time_zone_displacement_value","class":"22 — Data Exception"}
  "2200C":{"name":"invalid_use_of_escape_character","class":"22 — Data Exception"}
  "2200G":{"name":"most_specific_type_mismatch","class":"22 — Data Exception"}
  "22004":{"name":"null_value_not_allowed","class":"22 — Data Exception"}
  "22002":{"name":"null_value_no_indicator_parameter","class":"22 — Data Exception"}
  "22003":{"name":"numeric_value_out_of_range","class":"22 — Data Exception"}
  "22026":{"name":"string_data_length_mismatch","class":"22 — Data Exception"}
  "22001":{"name":"string_data_right_truncation","class":"22 — Data Exception"}
  "22011":{"name":"substring_error","class":"22 — Data Exception"}
  "22027":{"name":"trim_error","class":"22 — Data Exception"}
  "22024":{"name":"unterminated_c_string","class":"22 — Data Exception"}
  "2200F":{"name":"zero_length_character_string","class":"22 — Data Exception"}
  "22P01":{"name":"floating_point_exception","class":"22 — Data Exception"}
  "22P02":{"name":"invalid_text_representation","class":"22 — Data Exception"}
  "22P03":{"name":"invalid_binary_representation","class":"22 — Data Exception"}
  "22P04":{"name":"bad_copy_file_format","class":"22 — Data Exception"}
  "22P05":{"name":"untranslatable_character","class":"22 — Data Exception"}
  "2200L":{"name":"not_an_xml_document","class":"22 — Data Exception"}
  "2200M":{"name":"invalid_xml_document","class":"22 — Data Exception"}
  "2200N":{"name":"invalid_xml_content","class":"22 — Data Exception"}
  "2200S":{"name":"invalid_xml_comment","class":"22 — Data Exception"}
  "2200T":{"name":"invalid_xml_processing_instruction","class":"22 — Data Exception"}
  "23000":{"name":"integrity_constraint_violation","class":"23 — Integrity Constraint Violation"}
  "23001":{"name":"restrict_violation","class":"23 — Integrity Constraint Violation"}
  "23502":{"name":"not_null_violation","class":"23 — Integrity Constraint Violation"}
  "23503":{"name":"foreign_key_violation","class":"23 — Integrity Constraint Violation"}
  "23505":{"name":"unique_violation","class":"23 — Integrity Constraint Violation"}
  "23514":{"name":"check_violation","class":"23 — Integrity Constraint Violation"}
  "23P01":{"name":"exclusion_violation","class":"23 — Integrity Constraint Violation"}
  "24000":{"name":"invalid_cursor_state","class":"24 — Invalid Cursor State"}
  "25000":{"name":"invalid_transaction_state","class":"25 — Invalid Transaction State"}
  "25001":{"name":"active_sql_transaction","class":"25 — Invalid Transaction State"}
  "25002":{"name":"branch_transaction_already_active","class":"25 — Invalid Transaction State"}
  "25008":{"name":"held_cursor_requires_same_isolation_level","class":"25 — Invalid Transaction State"}
  "25003":{"name":"inappropriate_access_mode_for_branch_transaction","class":"25 — Invalid Transaction State"}
  "25004":{"name":"inappropriate_isolation_level_for_branch_transaction","class":"25 — Invalid Transaction State"}
  "25005":{"name":"no_active_sql_transaction_for_branch_transaction","class":"25 — Invalid Transaction State"}
  "25006":{"name":"read_only_sql_transaction","class":"25 — Invalid Transaction State"}
  "25007":{"name":"schema_and_data_statement_mixing_not_supported","class":"25 — Invalid Transaction State"}
  "25P01":{"name":"no_active_sql_transaction","class":"25 — Invalid Transaction State"}
  "25P02":{"name":"in_failed_sql_transaction","class":"25 — Invalid Transaction State"}
  "26000":{"name":"invalid_sql_statement_name","class":"26 — Invalid SQL Statement Name"}
  "27000":{"name":"triggered_data_change_violation","class":"27 — Triggered Data Change Violation"}
  "28000":{"name":"invalid_authorization_specification","class":"28 — Invalid Authorization Specification"}
  "28P01":{"name":"invalid_password","class":"28 — Invalid Authorization Specification"}
  "2B000":{"name":"dependent_privilege_descriptors_still_exist","class":"2B — Dependent Privilege Descriptors Still Exist"}
  "2BP01":{"name":"dependent_objects_still_exist","class":"2B — Dependent Privilege Descriptors Still Exist"}
  "2D000":{"name":"invalid_transaction_termination","class":"2D — Invalid Transaction Termination"}
  "2F000":{"name":"sql_routine_exception","class":"2F — SQL Routine Exception"}
  "2F005":{"name":"function_executed_no_return_statement","class":"2F — SQL Routine Exception"}
  "2F002":{"name":"modifying_sql_data_not_permitted","class":"2F — SQL Routine Exception"}
  "2F003":{"name":"prohibited_sql_statement_attempted","class":"2F — SQL Routine Exception"}
  "2F004":{"name":"reading_sql_data_not_permitted","class":"2F — SQL Routine Exception"}
  "34000":{"name":"invalid_cursor_name","class":"34 — Invalid Cursor Name"}
  "38000":{"name":"external_routine_exception","class":"38 — External Routine Exception"}
  "38001":{"name":"containing_sql_not_permitted","class":"38 — External Routine Exception"}
  "38002":{"name":"modifying_sql_data_not_permitted","class":"38 — External Routine Exception"}
  "38003":{"name":"prohibited_sql_statement_attempted","class":"38 — External Routine Exception"}
  "38004":{"name":"reading_sql_data_not_permitted","class":"38 — External Routine Exception"}
  "39000":{"name":"external_routine_invocation_exception","class":"39 — External Routine Invocation Exception"}
  "39001":{"name":"invalid_sqlstate_returned","class":"39 — External Routine Invocation Exception"}
  "39004":{"name":"null_value_not_allowed","class":"39 — External Routine Invocation Exception"}
  "39P01":{"name":"trigger_protocol_violated","class":"39 — External Routine Invocation Exception"}
  "39P02":{"name":"srf_protocol_violated","class":"39 — External Routine Invocation Exception"}
  "3B000":{"name":"savepoint_exception","class":"3B — Savepoint Exception"}
  "3B001":{"name":"invalid_savepoint_specification","class":"3B — Savepoint Exception"}
  "3D000":{"name":"invalid_catalog_name","class":"3D — Invalid Catalog Name"}
  "3F000":{"name":"invalid_schema_name","class":"3F — Invalid Schema Name"}
  "40000":{"name":"transaction_rollback","class":"40 — Transaction Rollback"}
  "40002":{"name":"transaction_integrity_constraint_violation","class":"40 — Transaction Rollback"}
  "40001":{"name":"serialization_failure","class":"40 — Transaction Rollback"}
  "40003":{"name":"statement_completion_unknown","class":"40 — Transaction Rollback"}
  "40P01":{"name":"deadlock_detected","class":"40 — Transaction Rollback"}
  "42000":{"name":"syntax_error_or_access_rule_violation","class":"42 — Syntax Error or Access Rule Violation"}
  "42601":{"name":"syntax_error","class":"42 — Syntax Error or Access Rule Violation"}
  "42501":{"name":"insufficient_privilege","class":"42 — Syntax Error or Access Rule Violation"}
  "42846":{"name":"cannot_coerce","class":"42 — Syntax Error or Access Rule Violation"}
  "42803":{"name":"grouping_error","class":"42 — Syntax Error or Access Rule Violation"}
  "42P20":{"name":"windowing_error","class":"42 — Syntax Error or Access Rule Violation"}
  "42P19":{"name":"invalid_recursion","class":"42 — Syntax Error or Access Rule Violation"}
  "42830":{"name":"invalid_foreign_key","class":"42 — Syntax Error or Access Rule Violation"}
  "42602":{"name":"invalid_name","class":"42 — Syntax Error or Access Rule Violation"}
  "42622":{"name":"name_too_long","class":"42 — Syntax Error or Access Rule Violation"}
  "42939":{"name":"reserved_name","class":"42 — Syntax Error or Access Rule Violation"}
  "42804":{"name":"datatype_mismatch","class":"42 — Syntax Error or Access Rule Violation"}
  "42P18":{"name":"indeterminate_datatype","class":"42 — Syntax Error or Access Rule Violation"}
  "42P21":{"name":"collation_mismatch","class":"42 — Syntax Error or Access Rule Violation"}
  "42P22":{"name":"indeterminate_collation","class":"42 — Syntax Error or Access Rule Violation"}
  "42809":{"name":"wrong_object_type","class":"42 — Syntax Error or Access Rule Violation"}
  "42703":{"name":"undefined_column","class":"42 — Syntax Error or Access Rule Violation"}
  "42883":{"name":"undefined_function","class":"42 — Syntax Error or Access Rule Violation"}
  "42P01":{"name":"undefined_table","class":"42 — Syntax Error or Access Rule Violation"}
  "42P02":{"name":"undefined_parameter","class":"42 — Syntax Error or Access Rule Violation"}
  "42704":{"name":"undefined_object","class":"42 — Syntax Error or Access Rule Violation"}
  "42701":{"name":"duplicate_column","class":"42 — Syntax Error or Access Rule Violation"}
  "42P03":{"name":"duplicate_cursor","class":"42 — Syntax Error or Access Rule Violation"}
  "42P04":{"name":"duplicate_database","class":"42 — Syntax Error or Access Rule Violation"}
  "42723":{"name":"duplicate_function","class":"42 — Syntax Error or Access Rule Violation"}
  "42P05":{"name":"duplicate_prepared_statement","class":"42 — Syntax Error or Access Rule Violation"}
  "42P06":{"name":"duplicate_schema","class":"42 — Syntax Error or Access Rule Violation"}
  "42P07":{"name":"duplicate_table","class":"42 — Syntax Error or Access Rule Violation"}
  "42712":{"name":"duplicate_alias","class":"42 — Syntax Error or Access Rule Violation"}
  "42710":{"name":"duplicate_object","class":"42 — Syntax Error or Access Rule Violation"}
  "42702":{"name":"ambiguous_column","class":"42 — Syntax Error or Access Rule Violation"}
  "42725":{"name":"ambiguous_function","class":"42 — Syntax Error or Access Rule Violation"}
  "42P08":{"name":"ambiguous_parameter","class":"42 — Syntax Error or Access Rule Violation"}
  "42P09":{"name":"ambiguous_alias","class":"42 — Syntax Error or Access Rule Violation"}
  "42P10":{"name":"invalid_column_reference","class":"42 — Syntax Error or Access Rule Violation"}
  "42611":{"name":"invalid_column_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "42P11":{"name":"invalid_cursor_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "42P12":{"name":"invalid_database_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "42P13":{"name":"invalid_function_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "42P14":{"name":"invalid_prepared_statement_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "42P15":{"name":"invalid_schema_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "42P16":{"name":"invalid_table_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "42P17":{"name":"invalid_object_definition","class":"42 — Syntax Error or Access Rule Violation"}
  "44000":{"name":"with_check_option_violation","class":"44 — WITH CHECK OPTION Violation"}
  "53000":{"name":"insufficient_resources","class":"53 — Insufficient Resources"}
  "53100":{"name":"disk_full","class":"53 — Insufficient Resources"}
  "53200":{"name":"out_of_memory","class":"53 — Insufficient Resources"}
  "53300":{"name":"too_many_connections","class":"53 — Insufficient Resources"}
  "53400":{"name":"configuration_limit_exceeded","class":"53 — Insufficient Resources"}
  "54000":{"name":"program_limit_exceeded","class":"54 — Program Limit Exceeded"}
  "54001":{"name":"statement_too_complex","class":"54 — Program Limit Exceeded"}
  "54011":{"name":"too_many_columns","class":"54 — Program Limit Exceeded"}
  "54023":{"name":"too_many_arguments","class":"54 — Program Limit Exceeded"}
  "55000":{"name":"object_not_in_prerequisite_state","class":"55 — Object Not In Prerequisite State"}
  "55006":{"name":"object_in_use","class":"55 — Object Not In Prerequisite State"}
  "55P02":{"name":"cant_change_runtime_param","class":"55 — Object Not In Prerequisite State"}
  "55P03":{"name":"lock_not_available","class":"55 — Object Not In Prerequisite State"}
  "57000":{"name":"operator_intervention","class":"57 — Operator Intervention"}
  "57014":{"name":"query_canceled","class":"57 — Operator Intervention"}
  "57P01":{"name":"admin_shutdown","class":"57 — Operator Intervention"}
  "57P02":{"name":"crash_shutdown","class":"57 — Operator Intervention"}
  "57P03":{"name":"cannot_connect_now","class":"57 — Operator Intervention"}
  "57P04":{"name":"database_dropped","class":"57 — Operator Intervention"}
  "58000":{"name":"system_error","class":"58 — System Error (errors external to PostgreSQL itself)"}
  "58030":{"name":"io_error","class":"58 — System Error (errors external to PostgreSQL itself)"}
  "58P01":{"name":"undefined_file","class":"58 — System Error (errors external to PostgreSQL itself)"}
  "58P02":{"name":"duplicate_file","class":"58 — System Error (errors external to PostgreSQL itself)"}
  "F0000":{"name":"config_file_error","class":"F0 — Configuration File Error"}
  "F0001":{"name":"lock_file_exists","class":"F0 — Configuration File Error"}
  "HV000":{"name":"fdw_error","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV005":{"name":"fdw_column_name_not_found","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV002":{"name":"fdw_dynamic_parameter_value_needed","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV010":{"name":"fdw_function_sequence_error","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV021":{"name":"fdw_inconsistent_descriptor_information","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV024":{"name":"fdw_invalid_attribute_value","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV007":{"name":"fdw_invalid_column_name","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV008":{"name":"fdw_invalid_column_number","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV004":{"name":"fdw_invalid_data_type","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV006":{"name":"fdw_invalid_data_type_descriptors","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV091":{"name":"fdw_invalid_descriptor_field_identifier","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00B":{"name":"fdw_invalid_handle","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00C":{"name":"fdw_invalid_option_index","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00D":{"name":"fdw_invalid_option_name","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV090":{"name":"fdw_invalid_string_length_or_buffer_length","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00A":{"name":"fdw_invalid_string_format","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV009":{"name":"fdw_invalid_use_of_null_pointer","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV014":{"name":"fdw_too_many_handles","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV001":{"name":"fdw_out_of_memory","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00P":{"name":"fdw_no_schemas","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00J":{"name":"fdw_option_name_not_found","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00K":{"name":"fdw_reply_handle","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00Q":{"name":"fdw_schema_not_found","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00R":{"name":"fdw_table_not_found","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00L":{"name":"fdw_unable_to_create_execution","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00M":{"name":"fdw_unable_to_create_reply","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "HV00N":{"name":"fdw_unable_to_establish_connection","class":"HV — Foreign Data Wrapper Error (SQL/MED)"}
  "P0000":{"name":"plpgsql_error","class":"P0 — PL/pgSQL Error"}
  "P0001":{"name":"raise_exception","class":"P0 — PL/pgSQL Error"}
  "P0002":{"name":"no_data_found","class":"P0 — PL/pgSQL Error"}
  "P0003":{"name":"too_many_rows","class":"P0 — PL/pgSQL Error"}
  "XX000":{"name":"internal_error","class":"XX — Internal Error"}
  "XX001":{"name":"data_corrupted","class":"XX — Internal Error"}
  "XX002":{"name":"index_corrupted","class":"XX — Internal Error"}

# For integration tests, it will connect to a different database.
conString =
  if process.env.testMode?
    'postgres://postgres:postgres@localhost:5432/testing_db'
  else
    'postgres://postgres:postgres@localhost:5432/node_shop'

module.exports = (whenConnected) ->
  pg.connect(conString, (err, con, done) ->
    if err
      if err.code?
        code = errorCodes[err.code]
        err.errorCodeName = code.name
        err.errorClass = code.class
      whenConnected(err)
    else
      query = (sql, args) ->
        new Promise((resolve, reject) ->
          con.query(sql, args, (err, rs) ->
            if err
              if typeof sql == 'object'
                err.sqlQuery = sql.text
                err.sqlArgs = sql.values
              else
                err.sqlQuery = sql
                if args then err.sqlArgs = args
              if err.code?
                code = errorCodes[err.code]
                err.errorCodeName = code.name
                err.errorClass = code.class
              reject(err)
            else
              resolve(rs)
          )
        )

      whenConnected(undefined, query, done)

  )
