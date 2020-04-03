{
  inner_num_sweep = {
    vtr_reg_weekly_inner_num_0_5  = (make_regression_tests { flags = "--inner_num 0.5"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_1_0  = (make_regression_tests { flags = "--inner_num 1.0"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_2_0  = (make_regression_tests { flags = "--inner_num 2.0"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_5_0  = (make_regression_tests { flags = "--inner_num 5.0"; }).vtr_reg_weekly;
    vtr_reg_weekly_inner_num_10_0 = (make_regression_tests { flags = "--inner_num 10.0"; }.vtr_reg_weekly;
  };
}
