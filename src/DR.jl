using Embeddings
countries = ["Afghanistan", "Algeria", "Angola", "Arabia", "Argentina", "Australia", "Bangladesh", "Brazil", "Britain", "Canada", "China", "Colombia", "Congo", "Egypt", "England", "Ethiopia", "France", "Germany", "Ghana", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Italy", "Japan", "Kenya", "Korea", "Madagascar", "Malaysia", "Mexico", "Morocco", "Mozambique", "Myanmar", "Nepal", "Nigeria", "Pakistan", "Peru", "Philippines", "Poland", "Russia", "South", "Spain", "Sudan", "Tanzania", "Thailand", "Uganda", "Ukraine", "Usa", "Uzbekistan", "Venezuela", "Vietnam", "Wales", "Yemen"]
usa_cities = ["Albuquerque", "Atlanta", "Austin", "Baltimore", "Boston", "Charlotte", "Chicago", "Columbus", "Dallas", "Denver", "Detroit", "Francisco", "Fresno", "Houston", "Indianapolis", "Jacksonville", "Las", "Louisville", "Memphis", "Mesa", "Milwaukee", "Nashville", "Omaha", "Philadelphia", "Phoenix", "Portland", "Raleigh", "Sacramento", "San", "Seattle", "Tucson", "Vegas", "Washington"]
world_capitals = ["Accra", "Algiers", "Amman", "Ankara", "Antananarivo", "Athens", "Baghdad", "Baku", "Bangkok", "Beijing", "Beirut", "Berlin", "Bogotá", "Brasília", "Bucharest", "Budapest", "Cairo", "Caracas", "Damascus", "Dhaka", "Hanoi", "Havana", "Jakarta", "Kabul", "Kampala", "Khartoum", "Kinshasa", "Kyiv", "Lima", "London", "Luanda", "Madrid", "Manila", "Minsk", "Moscow", "Nairobi", "Paris", "Pretoria", "Pyongyang", "Quito", "Rabat", "Riyadh", "Rome", "Santiago", "Seoul", "Singapore", "Stockholm", "Taipei", "Tashkent", "Tehran", "Tokyo", "Vienna", "Warsaw", "Yaoundé"]
animals = ["alpaca","camel","cattle","dog","dove","duck","ferret","goldfish","goose","rat","llama","mouse","pigeon","yak"]
china_cities = ["Shanghai", "Tianjin", "Shenzhen", "Chengdu", "Changsha", "Nanjing", "Chongqing", "Hefei", "Qinghai", "Jilin", "Heilongjiang"]
sports = ["archery","badminton","basketball","boxing","cycling","diving","equestrian","fencing","field","football","golf","gymnastics","handball","hockey","judo","kayak","pentathlon","polo","rowing","rugby","sailing","shooting","soccer","swimming","taekwondo","tennis","triathlon","volleyball","weightlifting","wrestling"]

words_by_class = [countries, usa_cities, world_capitals, china_cities, animals, sports]
all_words = reduce(vcat, words_by_class)
embedding_table = load_embeddings(Word2Vec; keep_words = all_words)
@assert Set(all_words) == Set(embedding_table.vocab)

embeddings = embedding_table.embeddings
all_words = embedding_table.vocab
classes = map(all_words) do word
    findfirst(col -> word ∈ col, [countries, usa_cities, world_capitals, china_cities, animals, sports])
end;

##
using MultivariateStats
using Plots
plotly()

#Direct projection -- no DR -- just throw away the information in the other axies
xs=embeddings
scatter(xs[1,:], xs[2,:], xs[3,:]; hover=all_words, zcolor=classes, color = :viridis, legend = false)

##
M = fit(PCA, embeddings; maxoutdim=3)
xs = transform(M, embeddings)
scatter(xs[1,:], xs[2,:], xs[3,:]; hover=all_words, zcolor=classes, color = :viridis, legend = false)

M = fit(ICA, embeddings, 3; maxiter = 1000, tol = 1)
xs = transform(M, embeddings)
scatter(xs[1,:], xs[2,:], xs[3,:]; hover=all_words, zcolor=classes, color = :viridis, legend = false)

using TSne
xs = tsne(embeddings', 3, 3, 1000, 20.0)'
scatter(xs[1,:], xs[2,:], xs[3,:]; hover=all_words, zcolor=classes, color = :viridis, legend = false)
