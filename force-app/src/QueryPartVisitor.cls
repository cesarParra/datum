public interface QueryPartVisitor {
  Object visit(SelectPart part);
  Object visit(LimitPart part);
  Object visit(OffsetPart part);
  Object visit(FromPart part);
  Object visit(EmptyPart part); // Probably doesn't need to accept visitors.
}
