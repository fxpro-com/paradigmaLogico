
:-dynamic sol/0.
sol.
:-dynamic chuva/0.
chuva.
:-dynamic neblina/0.
neblina.

bom:-sol,not chuva.
instavel:-sol,chuva.
deprimente:-chuva,neblina.

calor:-bom, not neblina.
frio:-deprimente, not sol.

