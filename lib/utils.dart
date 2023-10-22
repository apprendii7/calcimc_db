double imc(double? peso, altura) {
  altura = altura / 100;
  return ((peso ?? 0) / ((altura ?? 0) * (altura ?? 0)));
}

String mensagemImc(double imc) {
  switch (imc) {
    case < 16:
      return "Magreza grave";
    case >= 16 && < 17:
      return "Magreza moderada";
    case >= 17 && < 18.5:
      return "Magreza leve";
    case >= 18.5 && < 25:
      return "Saudável";
    case >= 25 && < 30:
      return "Sobrepeso";
    case >= 30 && < 35:
      return "Obesidade grau I";
    case >= 35 && < 40:
      return "Obesidade grau II (severa)";
    case >= 40:
      return "Obesidade grau III (mórbida)";
    default:
      return "Erro, tente novamente";
  }
}
