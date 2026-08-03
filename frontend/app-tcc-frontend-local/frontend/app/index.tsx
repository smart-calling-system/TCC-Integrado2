import { Text, View, StyleSheet, ScrollView } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";

// Página informativa do preview: o entregável deste projeto é um app
// FLUTTER (exigência do TCC), localizado em /app/TCC-Integrado-main/Tcc_Face.
// Este ambiente executa apenas React Native/Expo, portanto o app Flutter
// não pode ser visualizado aqui — baixe o código e rode com `flutter run`.

const TELAS = [
  { icon: "flash-outline", nome: "Splash Screen", desc: "Logo, nome do sistema e carregamento" },
  { icon: "home-outline", nome: "Tela Inicial", desc: "Data, hora, status Online/Offline e ações" },
  { icon: "scan-outline", nome: "Reconhecimento Facial", desc: "Simulação com círculo de enquadramento" },
  { icon: "checkmark-circle-outline", nome: "Sucesso", desc: "João da Silva • RA 202600123 • 3º DS" },
  { icon: "close-circle-outline", nome: "Erro", desc: "Face não reconhecida + Tentar novamente" },
  { icon: "time-outline", nome: "Histórico", desc: "Cards com aluno, entrada, saída, data e status" },
  { icon: "sync-outline", nome: "Sincronização", desc: "Internet, servidor, banco local e pendentes" },
  { icon: "settings-outline", nome: "Configurações", desc: "Tema, idioma, versão e sobre" },
];

export default function Index() {
  return (
    <SafeAreaView style={styles.safe} testID="flutter-info-screen">
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.logoBox} testID="app-logo">
          <Ionicons name="happy-outline" size={44} color="#FFFFFF" />
        </View>
        <Text style={styles.title}>FaceClass — Frontend Flutter</Text>
        <Text style={styles.subtitle}>
          Sistema de Controle de Presença Escolar por Reconhecimento Facial
        </Text>

        <View style={styles.notice} testID="flutter-notice-card">
          <Ionicons name="information-circle" size={22} color="#1565C0" />
          <Text style={styles.noticeText}>
            O entregável deste projeto é um aplicativo FLUTTER (exigência do TCC),
            criado em TCC-Integrado-main/Tcc_Face. Este preview executa apenas
            React Native, então baixe o código (Save to GitHub) e rode localmente
            com: flutter create . && flutter pub get && flutter run
          </Text>
        </View>

        <Text style={styles.sectionTitle}>Telas implementadas (8)</Text>
        {TELAS.map((t) => (
          <View key={t.nome} style={styles.card} testID={`tela-card-${t.nome}`}>
            <View style={styles.cardIcon}>
              <Ionicons name={t.icon as never} size={22} color="#1565C0" />
            </View>
            <View style={styles.cardBody}>
              <Text style={styles.cardTitle}>{t.nome}</Text>
              <Text style={styles.cardDesc}>{t.desc}</Text>
            </View>
          </View>
        ))}

        <Text style={styles.sectionTitle}>Entregáveis</Text>
        <View style={styles.card} testID="entregavel-codigo">
          <View style={styles.cardIcon}>
            <Ionicons name="folder-open-outline" size={22} color="#1565C0" />
          </View>
          <View style={styles.cardBody}>
            <Text style={styles.cardTitle}>TCC-Integrado-main/Tcc_Face/</Text>
            <Text style={styles.cardDesc}>
              App Flutter completo: core, models, repositories, providers,
              controllers, routes, screens e widgets
            </Text>
          </View>
        </View>
        <View style={styles.card} testID="entregavel-relatorio">
          <View style={styles.cardIcon}>
            <Ionicons name="document-text-outline" size={22} color="#1565C0" />
          </View>
          <View style={styles.cardBody}>
            <Text style={styles.cardTitle}>RELATORIO_DESENVOLVIMENTO_FRONTEND.md</Text>
            <Text style={styles.cardDesc}>
              Documentação técnica completa da etapa do frontend do TCC
            </Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: "#F4F6FA",
  },
  scroll: {
    padding: 24,
    paddingBottom: 48,
    maxWidth: 720,
    width: "100%",
    alignSelf: "center",
  },
  logoBox: {
    width: 80,
    height: 80,
    borderRadius: 24,
    backgroundColor: "#1565C0",
    alignItems: "center",
    justifyContent: "center",
    alignSelf: "center",
    marginTop: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: "800",
    color: "#1E293B",
    textAlign: "center",
    marginTop: 16,
  },
  subtitle: {
    fontSize: 14,
    color: "#64748B",
    textAlign: "center",
    marginTop: 6,
    marginBottom: 20,
  },
  notice: {
    flexDirection: "row",
    gap: 10,
    backgroundColor: "#E3F0FC",
    borderRadius: 16,
    padding: 16,
    marginBottom: 24,
  },
  noticeText: {
    flex: 1,
    fontSize: 13,
    lineHeight: 19,
    color: "#0D47A1",
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: "700",
    color: "#1E293B",
    marginBottom: 12,
    marginTop: 8,
  },
  card: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#FFFFFF",
    borderRadius: 16,
    borderWidth: 1,
    borderColor: "#E2E8F0",
    padding: 14,
    marginBottom: 10,
  },
  cardIcon: {
    width: 44,
    height: 44,
    borderRadius: 14,
    backgroundColor: "#E3F0FC",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  cardBody: {
    flex: 1,
  },
  cardTitle: {
    fontSize: 15,
    fontWeight: "700",
    color: "#1E293B",
  },
  cardDesc: {
    fontSize: 12.5,
    color: "#64748B",
    marginTop: 2,
    lineHeight: 18,
  },
});
