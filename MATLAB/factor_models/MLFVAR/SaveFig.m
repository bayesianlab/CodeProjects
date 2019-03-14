function[] = SaveFig(dirname, filename)

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = get(FigHandle, 'Number');
  saveas(FigHandle, fullfile(dirname, [filename, num2str(FigName), '.jpg']));
end
