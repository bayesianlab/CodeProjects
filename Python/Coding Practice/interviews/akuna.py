import time
let_dict = {'a': 1, 'b': 1, 'c': 2, 'd': 2, 'e': 2,
            'f': 3, 'g': 3, 'h': 3, 'i': 4, 'j': 4, 'k': 4,
            'l': 5, 'm': 5, 'n': 5, 'o': 6, 'p': 6, 'q': 6, 'r': 7,
            's': 7, 't': 7, 'u': 8, 'v': 8, 'w': 8, 'x': 9, 'y': 9, 'z': 9}


def countPoints(x):
    if(len(x) == 1):
        return let_dict[x]
    elif(x in let_dict):
        return let_dict[x]
    else:
        s = 0
        n = len(x)
        s += let_dict[x[n-1:n]] + countPoints(x[0:n-1])
        let_dict[x] = s
        return s


def isExtraordinary(y):
    if(not(countPoints(y) % len(y))):
        return True
    else:
        return False


def countSubstrings(input_str):
    n = len(input_str)
    nextra = len(input_str)
    for b in range(n):
        for e in range(b+2, n+1):
            if(isExtraordinary(input_str[b:e])):
                nextra += 1
    return nextra


s = time.time()
x = 'bcrocxcnimrwfkfayxhpeorpgbcswclvxulhtryvxvbsjqjkcuslldomqcjwderaararkhtucihjnyxzoqdhjwxoqhfsxizktokadnkdaqeuqpqxovrnvfregacickbbceawbfbpxvzntjtzwthgzzdzvflvbhokakzeoqbxmevihzuietztxyhvddagvapylqxzxltblpcnvzchwbdvaynjcxfepyqxizngbwvvummvwovldwloveysbkdoslsgetgiujxjfvaokywduarzmpwhyrutmjqtnynirgaorhzuteexgtlcrvqwrdsmxodegkmnfcklxogscoeeqievyvcbubjejbheruospnnqvpendeinnbeyhrowkddejhdnlhkxmulqrlwsntlioqaguepdmxzpaqcwaqzztgjnepiudstzrnytgcsvpobfwxplkbnwizqzrrjmigkdnwcxqhxthkmzqzkymfspgtlnxyyzlkegdtrayalltbmubhdkxsewbuysbwvefghlztdhcflhwrkjpxocbwrpbyxuxolikpkonbuapdrxfachoggijxojcuttcboueneykctpxjjihfglsqlagpiflmgyhkxryisfykowarwlsruppjneubjpbwvecyqjtnjrtqzasuaazvnqxjzybisadbhtqxnktjskksgjazlqiqzlynpsuxlqoqqtefbvdlxzocqiwzdqzvnnueyirocjpwurtmoowaoxsjiljsunoekminstcsfpstjnofvytchnbpylilossdakuispgzmtnvypnejtztpfmqcibymvkddyhamzlswwfxkzbpazyykoyzvqaqqxkubjyfwfpuvfhlniztfjuygmecswlgataldvunrhelieydhebacagxuwzefwbidcjnctjegmrqwikxgmocmswstiiwdsvxrsnnokzradiandokvqtozocopexzhmhvsevdtnrqdkznjikuufffbukumiwffccmvutpuyhmektfmuxaxwxgvjysnpseqthembqxeleryyurcihlhhrsvehtnubjmqbgasnaduraxgjgezbbsuewglxoiyszmihvrzshszuqgzhseozwbrougwvatbnriovktftmhvxtnktyimnptgwtswvownmyitmleuqiqksyjqtbwqqkezqdrxfesvwowodvhdllropcjjhwazrqccmwsxetmcwrkgshgxgfgxfefudlcuorkbxigzknduowhbvwqfclloyynuzyovsgawbfuxglxayueqsnxseexaubobnpqqohsmutktxorqvxccfxqctdlulkfaxgtisqlooukqsmijmxyicthqnctbierwhjquxjrlgzuwzhwhzczdkndqjvjpapcayyskcsqvxvsbnmcnoihelkeamhksfowytotmvtbrncsyjfisxyxhrwiwbkmespbhatkskbjrzicyotivfxkoiltpgadbwuvyvtfszwucdxvrlbexrteuaqivudeuhcettmenwnodjaynxnwduecgtfyeeaqlnuibazctcpybdpdwsxvvpuymeoaswaldebkqzlhrsmpuptolofwflbibwtfbgsmtfszolarmbdnwzsaujqxhpudsvqbgojcirsjrqsiwkohxezimdcbtddttwsucpgimkmoeaqomaywjrkgfhcjqauvvyzxatmiyiuspcvsooxekovdoslettpzurnmgmxmkuifqkzdiwlrrojervtaxmenkqdseongvfvcyvqftttwnwxyuggdydijrwiwmroebjuovwprylhqjinetoijwunvbcfictxbqqtikkhosxfficqaufavefujsxdcauicbuuhgymnlyngyjmbpdlsrdzjhovosaokynprsitdvdfveqkatohbvsjehwfnanvazihhcomumgubpaseygjgbntdnyqidyewezeffaqbkofkqfcvirwgk'
print(countSubstrings(x))
e = time.time()
print(e-s)
