from SuperMizerEval import * 

if __name__ == '__main__':

    # args = ['', 'Awsdevsql013', 'Market', 85078063]
    # proc = 'MizerEvalAction'
    '''
        All known seller output 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data=pd.read_csv('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data=data.astype(dt)
    data_copy = data.copy()
    args=[]
    proc=[]
    all_known= "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\allknown_output.csv"
    d=run_model_original(args, proc,data_copy, model_path, log_file=all_known)

    '''
        All 0 output 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    all0_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\all0_output.csv"
    run_model_original(args, proc,data_copy, model_path, log_file=all0_output)

    '''
        All 1 output
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    all1_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\all1_output.csv"
    run_model_all1(args, proc, data_copy, model_path, 
                                    log_file=all1_output)
    
    '''
        Average of output 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\average_output.csv"
    run_model_average_predictions(args, proc, data_copy, model_path, log_file=avg_output)

    '''
        Average weights 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_weights = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\weights_output.csv"
    run_model_average_weights(args, proc, data_copy, model_path, log_file=avg_weights)
    
    '''
        Paramount name change
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_paramount.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    paramount_name_change ="\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\paramount_output.csv"
    run_model_original(args, proc, data_copy, model_path, log_file=paramount_name_change)

    '''
        Weighted average weights output 
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\weighted_avg_weights_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    run_model_weighted_avg_weights(
        args, proc, data_copy, model_path, seller_weight_file_name, log_file=pinnacle_output)
    
    '''
         seller subset 5
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\subset5_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
         seller subset 10
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\subset10_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
         seller subset 15
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\data_with_marginprice_winbit_2801_zztop.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\subset15_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage',
                     'SellerName_cardinalfinancial',
                     'SellerName_nvr',
                     'SellerName_afn',
                     'SellerName_fbc',
                     'SellerName_americanpacific']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)

    '''
        Pinnacle output all0
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_all0_output.csv"
    run_model_original(
        args, proc, data_copy, model_path, log_file=pinnacle_output)
    
    '''
        Pinnacle output all1
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_all1_output.csv"
    run_model_all1(
        args, proc, data_copy, model_path, log_file=pinnacle_output)
    
    '''
        Pinnacle Paramount name change
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit_paramount.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    paramount_name_change ="\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_changename_output.csv"
    run_model_original(args, proc, data_copy, model_path, log_file=paramount_name_change)
    
    
    '''
        Pinnacle Average of output 
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_average_output.csv"
    run_model_average_predictions(args, proc, data_copy, model_path, log_file=avg_output)
    

    '''
        Pinnacle Average weights 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    # data = pd.read_csv(
    #     '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\zztop_data.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_weights = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_weights_output.csv"
    run_model_average_weights(args, proc, data_copy, model_path, log_file=avg_weights)
    
    '''
        Pinnacle Average waw 
    '''
    model_path = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\79747158'
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    avg_weights = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_waw_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    run_model_weighted_avg_weights(args, proc, data_copy, model_path, seller_weight_file_name, log_file=avg_weights)
    
    '''
        Pinnacle seller subset 5
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_subset5_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
        Pinnacle seller subset 10
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_subset10_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)
    
    '''
        Pinnacle seller subset 15
    '''
    data = pd.read_csv(
        '\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Data\\pinnacle_marginprice_winbit.csv')
    with open('\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Code\\dtypes.pkl', 'rb') as f:
        dt = pickle.load(f)
    data = data.astype(dt)
    data_copy = data.copy()
    args = []
    proc = []
    pinnacle_output = "\\\\corp.lan\\shares\\TradingDesk\\Analytics\\Aspen\\Margin Optimization\\Presentation\\Average Seller Presentation\\Results + Analysis\\Jan18\\pinnacle_subset15_output.csv"
    seller_weight_file_name = r'\\corp.lan\shares\TradingDesk\Analytics\Aspen\Margin Optimization\Presentation\Average Seller Presentation\Data\seller_weights.csv'
    seller_subset = ['SellerName_guaranteedrate',
                     'SellerName_crosscountrymortgage',
                     'SellerName_mortgageresearch',
                     'SellerName_kindlending',
                     'SellerName_prosperity',
                     'SellerName_arklatex',
                     'SellerName_paramount',
                     'SellerName_uamc',
                     'SellerName_churchillmortgage',
                     'SellerName_fairwayindependentmortgage',
                     'SellerName_cardinalfinancial',
                     'SellerName_nvr',
                     'SellerName_afn',
                     'SellerName_fbc',
                     'SellerName_americanpacific']

    run_model_all1_subset(
        args, proc, data_copy, model_path, seller_subset, log_file=pinnacle_output)

