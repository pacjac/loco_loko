alpha = linspace(0, 2*PI, 10)
for i = 1 : 10
p1.x(i) = cos(alpha(i))
p1.y(i) = sin(alpha(i))
p2.x(i) = cos(alpha(i))
p2.y(i) = -sin(alpha(i))
p3.x(i) = 0
p3.y(i) = 0
end

disp(alpha * 180 / PI)
disp(LawOfCosines(p1, p3, p2))
