public interface QueryPartVisitor {
  Object visit(SelectPart part, Object current);
  Object visit(SubselectPart part, Object current);
  Object visit(LimitPart part, Object current);
  Object visit(OffsetPart part, Object current);
  Object visit(FromPart part, Object current);
  Object visit(EmptyPart part, Object current);
}
