package l3;

import I.C0053n;
import android.util.Log;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.util.List;
import x3.AbstractC0729i;

/* JADX INFO: renamed from: l3.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0528e {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ C0528e f5679a = new C0528e();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final w3.f f5680b = new w3.f(new defpackage.c(2));

    public static O2.l a() {
        return (O2.l) f5680b.a();
    }

    public static void b(O2.f fVar, final InterfaceC0529f interfaceC0529f, String str) {
        J3.i.e(fVar, "binaryMessenger");
        String strConcat = str.length() > 0 ? ".".concat(str) : "";
        p1.d dVarM = fVar.m(new O2.k());
        C0053n c0053n = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setBool", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i4 = 6;
            c0053n.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i4) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n.y(null);
        }
        C0053n c0053n2 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setString", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i5 = 12;
            c0053n2.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i5) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n2.y(null);
        }
        C0053n c0053n3 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setInt", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i6 = 13;
            c0053n3.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i6) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n3.y(null);
        }
        C0053n c0053n4 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setDouble", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i7 = 14;
            c0053n4.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i7) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n4.y(null);
        }
        C0053n c0053n5 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setEncodedStringList", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i8 = 0;
            c0053n5.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i8) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n5.y(null);
        }
        C0053n c0053n6 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.setDeprecatedStringList", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i9 = 1;
            c0053n6.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i9) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n6.y(null);
        }
        C0053n c0053n7 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getString", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i10 = 2;
            c0053n7.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i10) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n7.y(null);
        }
        C0053n c0053n8 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getBool", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i11 = 3;
            c0053n8.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i11) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n8.y(null);
        }
        C0053n c0053n9 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getDouble", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i12 = 4;
            c0053n9.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i12) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n9.y(null);
        }
        C0053n c0053n10 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getInt", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i13 = 5;
            c0053n10.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i13) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n10.y(null);
        }
        C0053n c0053n11 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getPlatformEncodedStringList", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i14 = 7;
            c0053n11.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i14) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n11.y(null);
        }
        C0053n c0053n12 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getStringList", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i15 = 8;
            c0053n12.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i15) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n12.y(null);
        }
        C0053n c0053n13 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.clear", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i16 = 9;
            c0053n13.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i16) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n13.y(null);
        }
        C0053n c0053n14 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getAll", strConcat), a(), dVarM, 5);
        if (interfaceC0529f != null) {
            final int i17 = 10;
            c0053n14.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i17) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        } else {
            c0053n14.y(null);
        }
        C0053n c0053n15 = new C0053n(fVar, B1.a.m("dev.flutter.pigeon.shared_preferences_android.SharedPreferencesAsyncApi.getKeys", strConcat), a(), dVarM, 5);
        if (interfaceC0529f == null) {
            c0053n15.y(null);
        } else {
            final int i18 = 11;
            c0053n15.y(new O2.b() { // from class: l3.d
                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    List listT;
                    List listT2;
                    List listT3;
                    List listT4;
                    List listT5;
                    List listT6;
                    List listT7;
                    List listT8;
                    List listT9;
                    List listT10;
                    List listT11;
                    List listT12;
                    List listT13;
                    List listT14;
                    List listT15;
                    switch (i18) {
                        case 0:
                            InterfaceC0529f interfaceC0529f2 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list = (List) obj;
                            Object obj2 = list.get(0);
                            J3.i.c(obj2, "null cannot be cast to non-null type kotlin.String");
                            String str2 = (String) obj2;
                            Object obj3 = list.get(1);
                            J3.i.c(obj3, "null cannot be cast to non-null type kotlin.String");
                            String str3 = (String) obj3;
                            Object obj4 = list.get(2);
                            J3.i.c(obj4, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f2.p(str2, str3, (C0530g) obj4);
                                listT = e1.k.x(null);
                            } catch (Throwable th) {
                                listT = AbstractC0729i.T(th.getClass().getSimpleName(), th.toString(), "Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
                            }
                            vVar.f(listT);
                            break;
                        case 1:
                            InterfaceC0529f interfaceC0529f3 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list2 = (List) obj;
                            Object obj5 = list2.get(0);
                            J3.i.c(obj5, "null cannot be cast to non-null type kotlin.String");
                            String str4 = (String) obj5;
                            Object obj6 = list2.get(1);
                            J3.i.c(obj6, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
                            List list3 = (List) obj6;
                            Object obj7 = list2.get(2);
                            J3.i.c(obj7, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f3.d(str4, list3, (C0530g) obj7);
                                listT2 = e1.k.x(null);
                            } catch (Throwable th2) {
                                listT2 = AbstractC0729i.T(th2.getClass().getSimpleName(), th2.toString(), "Cause: " + th2.getCause() + ", Stacktrace: " + Log.getStackTraceString(th2));
                            }
                            vVar.f(listT2);
                            break;
                        case 2:
                            InterfaceC0529f interfaceC0529f4 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list4 = (List) obj;
                            Object obj8 = list4.get(0);
                            J3.i.c(obj8, "null cannot be cast to non-null type kotlin.String");
                            String str5 = (String) obj8;
                            Object obj9 = list4.get(1);
                            J3.i.c(obj9, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT3 = e1.k.x(interfaceC0529f4.e(str5, (C0530g) obj9));
                            } catch (Throwable th3) {
                                listT3 = AbstractC0729i.T(th3.getClass().getSimpleName(), th3.toString(), "Cause: " + th3.getCause() + ", Stacktrace: " + Log.getStackTraceString(th3));
                            }
                            vVar.f(listT3);
                            break;
                        case 3:
                            InterfaceC0529f interfaceC0529f5 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list5 = (List) obj;
                            Object obj10 = list5.get(0);
                            J3.i.c(obj10, "null cannot be cast to non-null type kotlin.String");
                            String str6 = (String) obj10;
                            Object obj11 = list5.get(1);
                            J3.i.c(obj11, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT4 = e1.k.x(interfaceC0529f5.f(str6, (C0530g) obj11));
                            } catch (Throwable th4) {
                                listT4 = AbstractC0729i.T(th4.getClass().getSimpleName(), th4.toString(), "Cause: " + th4.getCause() + ", Stacktrace: " + Log.getStackTraceString(th4));
                            }
                            vVar.f(listT4);
                            break;
                        case 4:
                            InterfaceC0529f interfaceC0529f6 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list6 = (List) obj;
                            Object obj12 = list6.get(0);
                            J3.i.c(obj12, "null cannot be cast to non-null type kotlin.String");
                            String str7 = (String) obj12;
                            Object obj13 = list6.get(1);
                            J3.i.c(obj13, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT5 = e1.k.x(interfaceC0529f6.l(str7, (C0530g) obj13));
                            } catch (Throwable th5) {
                                listT5 = AbstractC0729i.T(th5.getClass().getSimpleName(), th5.toString(), "Cause: " + th5.getCause() + ", Stacktrace: " + Log.getStackTraceString(th5));
                            }
                            vVar.f(listT5);
                            break;
                        case 5:
                            InterfaceC0529f interfaceC0529f7 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list7 = (List) obj;
                            Object obj14 = list7.get(0);
                            J3.i.c(obj14, "null cannot be cast to non-null type kotlin.String");
                            String str8 = (String) obj14;
                            Object obj15 = list7.get(1);
                            J3.i.c(obj15, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT6 = e1.k.x(interfaceC0529f7.j(str8, (C0530g) obj15));
                            } catch (Throwable th6) {
                                listT6 = AbstractC0729i.T(th6.getClass().getSimpleName(), th6.toString(), "Cause: " + th6.getCause() + ", Stacktrace: " + Log.getStackTraceString(th6));
                            }
                            vVar.f(listT6);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            InterfaceC0529f interfaceC0529f8 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list8 = (List) obj;
                            Object obj16 = list8.get(0);
                            J3.i.c(obj16, "null cannot be cast to non-null type kotlin.String");
                            String str9 = (String) obj16;
                            Object obj17 = list8.get(1);
                            J3.i.c(obj17, "null cannot be cast to non-null type kotlin.Boolean");
                            boolean zBooleanValue = ((Boolean) obj17).booleanValue();
                            Object obj18 = list8.get(2);
                            J3.i.c(obj18, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f8.n(str9, zBooleanValue, (C0530g) obj18);
                                listT7 = e1.k.x(null);
                            } catch (Throwable th7) {
                                listT7 = AbstractC0729i.T(th7.getClass().getSimpleName(), th7.toString(), "Cause: " + th7.getCause() + ", Stacktrace: " + Log.getStackTraceString(th7));
                            }
                            vVar.f(listT7);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            InterfaceC0529f interfaceC0529f9 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list9 = (List) obj;
                            Object obj19 = list9.get(0);
                            J3.i.c(obj19, "null cannot be cast to non-null type kotlin.String");
                            String str10 = (String) obj19;
                            Object obj20 = list9.get(1);
                            J3.i.c(obj20, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT8 = e1.k.x(interfaceC0529f9.k(str10, (C0530g) obj20));
                            } catch (Throwable th8) {
                                listT8 = AbstractC0729i.T(th8.getClass().getSimpleName(), th8.toString(), "Cause: " + th8.getCause() + ", Stacktrace: " + Log.getStackTraceString(th8));
                            }
                            vVar.f(listT8);
                            break;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            InterfaceC0529f interfaceC0529f10 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list10 = (List) obj;
                            Object obj21 = list10.get(0);
                            J3.i.c(obj21, "null cannot be cast to non-null type kotlin.String");
                            String str11 = (String) obj21;
                            Object obj22 = list10.get(1);
                            J3.i.c(obj22, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT9 = e1.k.x(interfaceC0529f10.h(str11, (C0530g) obj22));
                            } catch (Throwable th9) {
                                listT9 = AbstractC0729i.T(th9.getClass().getSimpleName(), th9.toString(), "Cause: " + th9.getCause() + ", Stacktrace: " + Log.getStackTraceString(th9));
                            }
                            vVar.f(listT9);
                            break;
                        case 9:
                            InterfaceC0529f interfaceC0529f11 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list11 = (List) obj;
                            List list12 = (List) list11.get(0);
                            Object obj23 = list11.get(1);
                            J3.i.c(obj23, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f11.q(list12, (C0530g) obj23);
                                listT10 = e1.k.x(null);
                            } catch (Throwable th10) {
                                listT10 = AbstractC0729i.T(th10.getClass().getSimpleName(), th10.toString(), "Cause: " + th10.getCause() + ", Stacktrace: " + Log.getStackTraceString(th10));
                            }
                            vVar.f(listT10);
                            break;
                        case 10:
                            InterfaceC0529f interfaceC0529f12 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list13 = (List) obj;
                            List list14 = (List) list13.get(0);
                            Object obj24 = list13.get(1);
                            J3.i.c(obj24, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT11 = e1.k.x(interfaceC0529f12.i(list14, (C0530g) obj24));
                            } catch (Throwable th11) {
                                listT11 = AbstractC0729i.T(th11.getClass().getSimpleName(), th11.toString(), "Cause: " + th11.getCause() + ", Stacktrace: " + Log.getStackTraceString(th11));
                            }
                            vVar.f(listT11);
                            break;
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            InterfaceC0529f interfaceC0529f13 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list15 = (List) obj;
                            List list16 = (List) list15.get(0);
                            Object obj25 = list15.get(1);
                            J3.i.c(obj25, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                listT12 = e1.k.x(interfaceC0529f13.g(list16, (C0530g) obj25));
                            } catch (Throwable th12) {
                                listT12 = AbstractC0729i.T(th12.getClass().getSimpleName(), th12.toString(), "Cause: " + th12.getCause() + ", Stacktrace: " + Log.getStackTraceString(th12));
                            }
                            vVar.f(listT12);
                            break;
                        case 12:
                            InterfaceC0529f interfaceC0529f14 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list17 = (List) obj;
                            Object obj26 = list17.get(0);
                            J3.i.c(obj26, "null cannot be cast to non-null type kotlin.String");
                            String str12 = (String) obj26;
                            Object obj27 = list17.get(1);
                            J3.i.c(obj27, "null cannot be cast to non-null type kotlin.String");
                            String str13 = (String) obj27;
                            Object obj28 = list17.get(2);
                            J3.i.c(obj28, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f14.a(str12, str13, (C0530g) obj28);
                                listT13 = e1.k.x(null);
                            } catch (Throwable th13) {
                                listT13 = AbstractC0729i.T(th13.getClass().getSimpleName(), th13.toString(), "Cause: " + th13.getCause() + ", Stacktrace: " + Log.getStackTraceString(th13));
                            }
                            vVar.f(listT13);
                            break;
                        case 13:
                            InterfaceC0529f interfaceC0529f15 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list18 = (List) obj;
                            Object obj29 = list18.get(0);
                            J3.i.c(obj29, "null cannot be cast to non-null type kotlin.String");
                            String str14 = (String) obj29;
                            Object obj30 = list18.get(1);
                            J3.i.c(obj30, "null cannot be cast to non-null type kotlin.Long");
                            long jLongValue = ((Long) obj30).longValue();
                            Object obj31 = list18.get(2);
                            J3.i.c(obj31, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f15.b(str14, jLongValue, (C0530g) obj31);
                                listT14 = e1.k.x(null);
                            } catch (Throwable th14) {
                                listT14 = AbstractC0729i.T(th14.getClass().getSimpleName(), th14.toString(), "Cause: " + th14.getCause() + ", Stacktrace: " + Log.getStackTraceString(th14));
                            }
                            vVar.f(listT14);
                            break;
                        default:
                            InterfaceC0529f interfaceC0529f16 = interfaceC0529f;
                            J3.i.c(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.Any?>");
                            List list19 = (List) obj;
                            Object obj32 = list19.get(0);
                            J3.i.c(obj32, "null cannot be cast to non-null type kotlin.String");
                            String str15 = (String) obj32;
                            Object obj33 = list19.get(1);
                            J3.i.c(obj33, "null cannot be cast to non-null type kotlin.Double");
                            double dDoubleValue = ((Double) obj33).doubleValue();
                            Object obj34 = list19.get(2);
                            J3.i.c(obj34, "null cannot be cast to non-null type io.flutter.plugins.sharedpreferences.SharedPreferencesPigeonOptions");
                            try {
                                interfaceC0529f16.o(str15, dDoubleValue, (C0530g) obj34);
                                listT15 = e1.k.x(null);
                            } catch (Throwable th15) {
                                listT15 = AbstractC0729i.T(th15.getClass().getSimpleName(), th15.toString(), "Cause: " + th15.getCause() + ", Stacktrace: " + Log.getStackTraceString(th15));
                            }
                            vVar.f(listT15);
                            break;
                    }
                }
            });
        }
    }
}
