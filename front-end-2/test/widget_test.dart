import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_face/main.dart';

void main() {
  testWidgets('app inicializa na splash', (tester) async {
    await tester.pumpWidget(const TccFaceApp());
    expect(find.text('FaceClass'), findsWidgets);
  });
}
