

float interpolate(int x, vector<pair<int, float>> points)
{
    float x0 = points[0].first;
    float y0 = points[0].second;
    float x1 = points[1].first;
    float y1 = points[1].second; 
    // cout << x << " " << x0 << " " << y0 << " " << x1 << " " << y1 << endl;
    return y0 + (x-x0)*(y1-y0)/(x1-x0);
}


void calcMissing(vector<string> readings) {
    vector<float> Y;
    vector<struct tm> tX; 
    for(vector<string>::iterator it = readings.begin(); it != readings.end(); ++it)
    {
        string n = it->substr(it->find("\t"));
        if(n.find("Missing") != string::npos)
        {
            Y.push_back(1000);
        }
        else
        {
            Y.push_back(stod(n));     
        }
    }
    
    vector<int> X(Y.size());
    iota(X.begin(), X.end(), 0);
    int i = 0;
    vector<float> inputed; 
    while( i < X.size())
    {
        vector<pair<int, float>> interpoints; 
        int xval = X[i]; 
        if(i == 0 && Y[i] == 1000)
        {
            int fillTwo = 0;
            int j = i; 
            while(fillTwo < 2)
            {
                ++j;
                if(Y[j] != 1000)
                {
                    interpoints.push_back(make_pair(X[j], Y[j]));
                    ++fillTwo; 
                }
            }
            inputed.push_back(interpolate(xval, interpoints));
            interpoints.clear();
        }
        else
        {
            if(i==1 && Y[i+1] == 1000)
            {
                interpoints.push_back(make_pair(X[0], Y[0]));
                int findnext = 1;
                int j = i; 
                while(findnext < 2)
                {
                    ++j; 
                    if(Y[j] != 1000)
                    {
                        interpoints.push_back(make_pair(X[j], Y[j]));
                        ++findnext;
                    }
                }
                inputed.push_back(interpolate(xval, interpoints));
                interpoints.clear();
            }
            else if(Y[i] == 1000)
            {
                int r1=i;
                int r2=i;
                int findTwo = 0;
                while(findTwo < 2)
                {
                    ++r1;
                    --r2;
                    if(r1 < Y.size() && Y[r1] != 1000)
                    {
                        ++findTwo;
                        interpoints.push_back(make_pair(X[r1], Y[r1]));
                    }
                    if(r2>=0 && Y[r2] != 1000 && interpoints.size() < 2)
                    {
                        ++findTwo;
                        interpoints.push_back(make_pair(X[r2], Y[r2]));
                    }
                }
                inputed.push_back(interpolate(xval, interpoints));
                interpoints.clear();
            }
        }
        ++i;
    }
}