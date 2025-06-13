
# K\-NN explained

Explain K\-Nearest Neighbors with music

## Setup

Python environment

```matlab
setup_python
```

Get secrets from [developer.spotify.com](https://developer.spotify.com/) 

```matlab
loadenv(".env")
sp = createSpotifyClient(getenv("clientId"),getenv("clientSecret"));
```
## Search
```matlab
query = "lucy in the sky with diamonds";
% query = "shine on your crazy diamonds";
T = searchTrack(sp,query)
```
| |track_id|track_name|artist_name|album_name|album_url|
|:--:|:--:|:--:|:--:|:--:|:--:|
|1|"7ioKlCkz1gjZmOBLU1mP1Z"|"Lucy in the Sky with Diamonds (Live)"|"Katie Melua"|"B-Sides: The Tracks That Got Away"|"https://i.scdn.co/image/ab67616d00001e022e524a09b1105d15fcbc4c2d"|
|2|"25yQPHgC35WNnnOUqFhgVR"|"Lucy In The Sky With Diamonds - Remastered 2009"|"The Beatles"|"Sgt. Pepper's Lonely Hearts Club Band (Remastered)"|"https://i.scdn.co/image/ab67616d00001e0234ef8f7d06cf2fc2146f420a"|
|3|"6ayD6m0NsLwSEclhTaSAvX"|"Lucy In The Sky With Diamonds"|"The Chris Eagan Project"|"Beatles Guitar Tracks - My Way"|"https://i.scdn.co/image/ab67616d00001e02f57ef327a555ac893d5d8606"|
|4|"0YG4aZm33LuWiHhlwdSgVI"|"NeoVanDeeAvatar"|"Flow_GPo.eth.oven"|"WelComeBackMyDeer - Marcel Hirscher"|"https://i.scdn.co/image/ab67616d00001e025ab6bf3d9a96f76f0f305ba6"|
|5|"5wLkhxwU7B9DNglfZAIrQ8"|"Lucy In The Sky With Diamonds"|"The Beatles"|"Yellow Submarine Songtrack"|"https://i.scdn.co/image/ab67616d00001e02d807dd713cdfbeed142881e2"|
|6|"09NgjM6dqRqCReWIZL2l0W"|"Lucy in the Sky with Diamonds"|"Frank Arricale"|"Off the Beatle Track"|"https://i.scdn.co/image/ab67616d00001e02040d0d9181d5bdd1b1be06ff"|
|7|"6KDhd9lR1JR41ZgrOfGmKj"|"Lucy in the Sky With Diamonds"|"101 Strings Orchestra"|"The Beatles played by the 101 Strings Orchestra"|"https://i.scdn.co/image/ab67616d00001e021daf1435bd5cf31668d349e6"|
|8|"7eyNpJhRRm3q8uHLkrFzmQ"|"Lucy In The Sky With Diamonds - From "Across The Universe" Soundtrack"|"Bono"|"Across The Universe"|"https://i.scdn.co/image/ab67616d00001e025c3e6bc8c0ddcc78d85fac6a"|
|9|"15KTU3BWhyY02oN9VBuHOM"|"Lucy in the Sky With Diamonds (In the Style of the Beatles) [Performance Track with Demonstration Vocals]"|"Done Again"|"Lucy in the Sky With Diamonds (In the Style of the Beatles) [Performance Track with Demonstration Vocals]"|"https://i.scdn.co/image/ab67616d00001e0299be84b01f2d124a0dbfae96"|
|10|"5b63KquzbqgfE4k6KFUaV7"|"Lucy in the Sky With Diamonds"|"101 Strings Orchestra"|"Easy Listening: Songs of The Beatles"|"https://i.scdn.co/image/ab67616d00001e02c785501c0f3ea71b8796e7be"|

```matlab
result =  T(2,:);
imshow(imread(result.album_url))
```

![figure_0.png](README_media/figure_0.png)

```matlab
track_features = getFeatures(sp,result.track_id)
```

```matlabTextOutput
track_features = struct with fields:
        acousticness: 0.0469
        danceability: 0.3110
              energy: 0.3250
    instrumentalness: 0
            liveness: 0.1390
         speechiness: 0.0283
             valence: 0.6680

```

```matlab
plotFeatures(track_features)
```

![figure_1.png](README_media/figure_1.png)
## Utils
```matlab
function sp = createSpotifyClient(clientId,clientSecret)
    spotipy = py.importlib.import_module('spotipy');
    auth_manager = spotipy.oauth2.SpotifyClientCredentials(client_id=clientId, client_secret=clientSecret);
    sp = spotipy.Spotify(auth_manager = auth_manager);
end

function result = searchTrack1(sp,query)
    res = sp.search(q="track: "+ query, type = "track");
    items = res{'tracks'}{'items'};
    result.track_id = string(items{1}{'id'});
    result.track_name = string(items{1}{'name'});
    result.track_artist = string(items{1}{'artists'}{1}{'name'});
    result.track_album = string(items{1}{'album'}{'name'});
end

function T = searchTrack(sp, query)
res = sp.search(q="track: "+ query, type = "track");
items = res{'tracks'}{'items'};
result = pyrun("track_results = [{" + ...
    "'track_id': item['id']," + ...
    "'track_name': item['name']," + ...
    "'artist_name': item['artists'][0]['name']," + ...
    "'album_name': item['album']['name']," + ...
    "'album_url': item['album']['images'][1]['url']}" + ...
    "for item in items]", "track_results",items=items);
T = table(py.pandas.DataFrame(result));
end

function track_features = getFeatures(sp,track_id)
    track_features = sp.audio_features(track_id);
    track_features = struct(track_features{1});
    labels = {'acousticness','danceability','energy','instrumentalness','liveness','speechiness','valence'};
    allFields = fieldnames(track_features);
    toRemove  = setdiff(allFields, labels);
    track_features = rmfield(track_features, toRemove);
    track_features = orderfields(track_features);
    % loop over each field and cast to double
    for k = 1:numel(labels)
        track_features.(labels{k}) = double(track_features.(labels{k}));
    end
end

function plotFeatures(track_features)
    % --- Given struct of track features ------------------------------------
    % track_features = struct( ...
    %    'danceability',    0.5170, ...
    %    'energy',          0.5060, ...
    %    'loudness',       -10.9180, ...
    %    'speechiness',     0.0311, ...
    %    'acousticness',    0.4310, ...
    %    'instrumentalness',9.6000e-04, ...
    %    'liveness',        0.9660, ...
    %    'valence',         0.4570);
    
    % 1) Extract labels & values
    labels = fieldnames(track_features);
    stats  = cell2mat(struct2cell(track_features))';   % row vector
    
    % 2) Close the loop
    nVars = numel(stats);
    theta = linspace(0,2*pi,nVars+1);   % includes endpoint 2π
    rho   = [stats, stats(1)];          % append first stat at end
    
    % 3) Convert to Cartesian
    [x, y] = pol2cart(theta, rho);
    
    % --- Build the plot -----------------------------------------------------
    figure('Position',[100 100 600 600]);
    hold on;
    axis equal off;
    
    % 4) Draw radial grid circles
    rTicks = [0.2 0.4 0.6 0.8];
    tGrid  = linspace(0,2*pi,200);
    for r = rTicks
        plot(r*cos(tGrid), r*sin(tGrid), ':', 'LineWidth', 1, 'Color', [0.8 0.8 0.8]);
    end
    
    % 5) Draw spokes
    for k = 1:nVars
        th = theta(k);
        plot([0 cos(th)], [0 sin(th)], '-', 'LineWidth', 1, 'Color', [0.8 0.8 0.8]);
    end
    
    % 6) Fill area & outline
    fill(x, y, 0.5*[1 1 1], 'FaceAlpha', 0.25, 'EdgeColor', 'none');
    plot(x, y, '-o', 'LineWidth', 2, 'Color', 0.5*[1 1 1]);
    
    % 7) Feature labels around the outside
    labelRadius = 1;  % just outside the unit circle
    for k = 1:nVars
        th = theta(k);
        text(labelRadius*cos(th), labelRadius*sin(th), labels{k}, ...
             'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    
    % 8) Radial-tick labels at ~250°
    labelAngle = deg2rad(250);
    for r = rTicks
        text(r*cos(labelAngle), r*sin(labelAngle), sprintf('%.1f', r), ...
             'FontSize', 12, 'Color', [0.4 0.4 0.4], ...
             'HorizontalAlignment','center');
    end
    
    % title('Track Feature Radar Chart');
    hold off;
end
```

```matlab
export livescript.mlx README.md;
```
