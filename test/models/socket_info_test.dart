import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:biot/app/app.locator.dart';
import 'package:biot/constants/amputation_info.dart';
import 'package:biot/constants/compass_lead_enum.dart';
import 'package:biot/model/socket_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../helpers/test_helpers.dart';

void main() {
  late SocketInfo socketInfo;
  late PdfDocument pdf;
  const int index = 0;
  group('Socket info tests', () {
    setUp(() async {
      registerServices();

      socketInfo = SocketInfo();
      Uint8List data = await File(
              '${Directory.current.path}/test/test_resources/episode_of_care_page.pdf')
          .readAsBytes();
      pdf = PdfDocument(inputBytes: data);
    });

    tearDown(() => locator.reset());

    test('No response', () {
      expect(socketInfo.toJsonForPDF(index), {});

      pdf.form.importData(
          utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
          DataFormat.json);
    });

    group('Side', () {
      test('Left', () {
        socketInfo.side = AmputationSide.left;

        expect(socketInfo.toJsonForPDF(index),
            {'side_$index': AmputationSide.left.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Right', () {
        socketInfo.side = AmputationSide.right;

        expect(socketInfo.toJsonForPDF(index),
            {'side_$index': AmputationSide.right.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Hemicorporectomy', () {
        socketInfo.side = AmputationSide.hemicorporectomy;

        expect(socketInfo.toJsonForPDF(index),
            {'side_$index': AmputationSide.hemicorporectomy.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    test('Date of delivery', () {
      socketInfo.dateOfDelivery = DateTime(2024, 4, 4);

      expect(socketInfo.toJsonForPDF(index), {'date_$index': '2024-04-04'});

      pdf.form.importData(
          utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
          DataFormat.json);
    });

    group('Socket', () {
      test('Partial foot', () {
        socketInfo.socket = Socket.partialFoot;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.partialFoot.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Ankle disarticulation', () {
        socketInfo.socket = Socket.ankleDisarticulation;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.ankleDisarticulation.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Transtibial', () {
        socketInfo.socket = Socket.transTibial;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.transTibial.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Knee disarticulation', () {
        socketInfo.socket = Socket.kneeDisarticulation;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.kneeDisarticulation.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Transfemoral', () {
        socketInfo.socket = Socket.transfemoral;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.transfemoral.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Hip disarticulation', () {
        socketInfo.socket = Socket.hipDisarticulation;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.hipDisarticulation.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Hemi-Pelvectomy', () {
        socketInfo.socket = Socket.hemiPelvectomy;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.hemiPelvectomy.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Hemicorporectomy', () {
        socketInfo.socket = Socket.hemicorporectomy;

        expect(socketInfo.toJsonForPDF(index),
            {'socket_$index': Socket.hemicorporectomy.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    group('Partial foot', () {
      test('Within shoe', () {
        socketInfo.partialFootDesign = PartialFootDesign.withinShoe;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': PartialFootDesign.withinShoe.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Ankle immobilised', () {
        socketInfo.partialFootDesign = PartialFootDesign.ankleImmobilized;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': PartialFootDesign.ankleImmobilized.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Ankle immobilised and weight borne proximally', () {
        socketInfo.partialFootDesign =
            PartialFootDesign.ankleImmobilizedWgtBorneProx;

        expect(socketInfo.toJsonForPDF(index), {
          'design_$index':
              PartialFootDesign.ankleImmobilizedWgtBorneProx.displayName
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    group('Ankle disarticulation', () {
      test('Split socket', () {
        socketInfo.ankleDisarticulationDesign =
            AnkleDisarticulationDesign.splitSocket;

        expect(socketInfo.toJsonForPDF(index), {
          'design_$index': AnkleDisarticulationDesign.splitSocket.displayName
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Window', () {
        socketInfo.ankleDisarticulationDesign =
            AnkleDisarticulationDesign.window;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': AnkleDisarticulationDesign.window.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Total surface bearing', () {
        socketInfo.ankleDisarticulationDesign =
            AnkleDisarticulationDesign.totalSurfaceBearing;

        expect(socketInfo.toJsonForPDF(index), {
          'design_$index':
              AnkleDisarticulationDesign.totalSurfaceBearing.displayName
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    group('Trans tibial', () {
      test('Patella tendon bearing', () {
        socketInfo.transTibialDesign = TransTibialDesign.patellaTendonBearing;

        expect(socketInfo.toJsonForPDF(index), {
          'design_$index': TransTibialDesign.patellaTendonBearing.displayName
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Specific weight bearing', () {
        socketInfo.transTibialDesign = TransTibialDesign.specificWeightBearing;

        expect(socketInfo.toJsonForPDF(index), {
          'design_$index': TransTibialDesign.specificWeightBearing.displayName
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Total surface bearing', () {
        socketInfo.transTibialDesign = TransTibialDesign.totalSurfaceBearing;

        expect(socketInfo.toJsonForPDF(index), {
          'design_$index': TransTibialDesign.totalSurfaceBearing.displayName
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Hydrostatic', () {
        socketInfo.transTibialDesign = TransTibialDesign.hydrostatic;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransTibialDesign.hydrostatic.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Thigh lacer', () {
        socketInfo.transTibialDesign = TransTibialDesign.thighLacer;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransTibialDesign.thighLacer.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Osseointegration', () {
        socketInfo.transTibialDesign = TransTibialDesign.osseointegration;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransTibialDesign.osseointegration.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    group('Knee disarticulation', () {
      test('Window', () {
        socketInfo.kneeDisarticulationDesign = KneeDisarticulationDesign.window;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': KneeDisarticulationDesign.window.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('No window', () {
        socketInfo.kneeDisarticulationDesign =
            KneeDisarticulationDesign.noWindow;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': KneeDisarticulationDesign.noWindow.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    group('Transfemoral', () {
      test('Quadrilateral (Ischial support and Narrow AP)', () {
        socketInfo.transfemoralDesign = TransfemoralDesign.quadrilateral;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransfemoralDesign.quadrilateral.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Narrow ML', () {
        socketInfo.transfemoralDesign = TransfemoralDesign.narrowMl;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransfemoralDesign.narrowMl.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Plug fit', () {
        socketInfo.transfemoralDesign = TransfemoralDesign.plugFit;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransfemoralDesign.plugFit.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Ischial containment', () {
        socketInfo.transfemoralDesign = TransfemoralDesign.ischialContainment;

        expect(socketInfo.toJsonForPDF(index), {
          'design_$index': TransfemoralDesign.ischialContainment.displayName
        });

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Sub Ischial', () {
        socketInfo.transfemoralDesign = TransfemoralDesign.subIschial;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransfemoralDesign.subIschial.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Osseointegration', () {
        socketInfo.transfemoralDesign = TransfemoralDesign.osseointegration;

        expect(socketInfo.toJsonForPDF(index),
            {'design_$index': TransfemoralDesign.osseointegration.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    test('Socket types', () {
      socketInfo.socketTypes = SocketType.values.map((e) => e).toList();

      Map<String, String> matcher = {};
      socketInfo.socketTypes!
          .map((e) => matcher.addAll({'type_${index}_${e.index}': 'Yes'}));

      pdf.form.importData(
          utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
          DataFormat.json);
    });

    group('Liner', () {
      test('No liner', () {
        socketInfo.liner = Liner.noLiner;

        expect(socketInfo.toJsonForPDF(index),
            {'liner_$index': Liner.noLiner.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Foam/pelite', () {
        socketInfo.liner = Liner.foamPelite;

        expect(socketInfo.toJsonForPDF(index),
            {'liner_$index': Liner.foamPelite.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Silicone', () {
        socketInfo.liner = Liner.silicone;

        expect(socketInfo.toJsonForPDF(index),
            {'liner_$index': Liner.silicone.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Urethane', () {
        socketInfo.liner = Liner.urethane;

        expect(socketInfo.toJsonForPDF(index),
            {'liner_$index': Liner.urethane.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Gel', () {
        socketInfo.liner = Liner.gel;

        expect(socketInfo.toJsonForPDF(index),
            {'liner_$index': Liner.gel.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    group('Suspension', () {
      test('Self-suspending', () {
        socketInfo.suspension = Suspension.selfSuspending;

        expect(socketInfo.toJsonForPDF(index),
            {'suspension_$index': Suspension.selfSuspending.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Cuff/strap', () {
        socketInfo.suspension = Suspension.cuffStrap;

        expect(socketInfo.toJsonForPDF(index),
            {'suspension_$index': Suspension.cuffStrap.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Pin', () {
        socketInfo.suspension = Suspension.pin;

        expect(socketInfo.toJsonForPDF(index),
            {'suspension_$index': Suspension.pin.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Lanyard', () {
        socketInfo.suspension = Suspension.lanyard;

        expect(socketInfo.toJsonForPDF(index),
            {'suspension_$index': Suspension.lanyard.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Sleeve', () {
        socketInfo.suspension = Suspension.sleeve;

        expect(socketInfo.toJsonForPDF(index),
            {'suspension_$index': Suspension.sleeve.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });

      test('Expulsion valve', () {
        socketInfo.suspension = Suspension.expulsionValve;

        expect(socketInfo.toJsonForPDF(index),
            {'suspension_$index': Suspension.expulsionValve.displayName});

        pdf.form.importData(
            utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
            DataFormat.json);
      });
    });

    test('Prosthetic foot types', () {
      socketInfo.prostheticFootTypes = ProstheticFootType.values.map((e) => e).toList();

      Map<String, String> matcher = {};
      socketInfo.prostheticFootTypes!.map((e) => matcher.addAll({
        'foot_${index}_${e.index}': 'Yes'
      })).toList();

      expect(socketInfo.toJsonForPDF(index), matcher);

      pdf.form.importData(
          utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
          DataFormat.json);
    });

    test('Prosthetic knee types', () {
      socketInfo.prostheticKneeTypes = ProstheticKneeType.values.map((e) => e).toList();

      Map<String, String> matcher = {};
      socketInfo.prostheticKneeTypes!.map((e) => matcher.addAll({
        'knee_${index}_${e.index}': 'Yes'
      })).toList();

      expect(socketInfo.toJsonForPDF(index), matcher);

      pdf.form.importData(
          utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
          DataFormat.json);
    });

    test('Prosthetic hip types', () {
      socketInfo.prostheticHipTypes = ProstheticHipType.values.map((e) => e).toList();

      Map<String, String> matcher = {};
      socketInfo.prostheticHipTypes!.map((e) => matcher.addAll({
        'hip_${index}_${e.index}': 'Yes'
      })).toList();

      expect(socketInfo.toJsonForPDF(index), matcher);

      pdf.form.importData(
          utf8.encode(jsonEncode(socketInfo.toJsonForPDF(index))),
          DataFormat.json);
    });
  });
}
