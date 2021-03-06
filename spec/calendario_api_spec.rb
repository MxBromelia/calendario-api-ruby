RSpec.describe CalendarioApi do
  let(:token) { ENV['CALENDARIO_API_TOKEN'] }
  context '.busca_feriados' do
    context 'Token Válido' do
      it 'retorna feriados nacionais do ano', vcr: 'feriados/brasil_2020' do
        listagem = CalendarioApi.busca_feriados token: token, ano: 2020

        expect(listagem.map(&:tipo).uniq).to include('Feriado Nacional')
      end

      it 'retorna os feriados nacionais e estaduais', vcr: 'feriados/brasil_sp_2020' do
        listagem = CalendarioApi.busca_feriados token: token, ano: 2020, estado: 'SP'

        expect(listagem.map(&:tipo).uniq).to include('Feriado Nacional', 'Feriado Estadual')
        expect(listagem.map(&:tipo).uniq).to_not include('Feriado Municipal')
      end

      it 'retorna os feriados nacionais e municipais', vcr: 'feriados/brasil_sao_paulo_2020' do
        listagem = CalendarioApi.busca_feriados token: token, ano: 2020, cidade: 'SAO_PAULO'

        expect(listagem.map(&:tipo).uniq).to include('Feriado Nacional', 'Feriado Municipal')
        expect(listagem.map(&:tipo).uniq).to_not include('Feriado Estadual')
      end

      it 'retorna os feriados nacionais, estaduais e municipais', vcr: 'feriados/brasil_sp_sao_paulo_2020' do
        listagem = CalendarioApi.busca_feriados token: token, ano: 2020, estado: 'SP', cidade: 'SAO_PAULO'

        expect(listagem.map(&:tipo).uniq).to include('Feriado Nacional', 'Feriado Estadual', 'Feriado Municipal')
      end
    end

    context 'Token Inválido' do
      it 'lança um erro de autenticação', vcr: 'feriados/brasil_2020_notoken' do
        expect { CalendarioApi.busca_feriados ano: 2020 }
          .to raise_error(CalendarioApi::TokenInvalido)
      end
    end

    # context 'Passou do limite de usos', vcr: 'feriados/limite_ultrapassado' do
    #   it 'lança um erro' do
    #     expect {
    #       CalendarioApi::Feriado.busca_feriados(token: token, ano: 2020, cidade: 'RIO_DE_JANEIRO', estado: 'RJ')
    #     }.to raise_error(CalendarioApi::LimiteUltrapassado)
    #   end
    # end
  end

  context '.busca_cidades', vcr: 'cidades' do
    it 'retorna as cidades do Brasil' do
      listagem = CalendarioApi.busca_cidades

      expect(listagem.count).to(be > 0)
      expect(listagem.first).to be_a(CalendarioApi::Cidade)
    end
  end
end
