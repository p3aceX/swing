package l3;

import I.C0053n;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import e1.AbstractC0367g;
import java.io.IOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import y0.C0747k;

/* JADX INFO: renamed from: l3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0524a implements K2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public SharedPreferences f5672a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final X.N f5673b = new X.N(21);

    public static void e(O2.f fVar, final C0524a c0524a) {
        p1.d dVarM = fVar.m(new O2.k());
        C0525b c0525b = C0525b.e;
        C0053n c0053n = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.remove", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i4 = 0;
            c0053n.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i4) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n.y(null);
        }
        C0053n c0053n2 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.setBool", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i5 = 1;
            c0053n2.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i5) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n2.y(null);
        }
        C0053n c0053n3 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.setString", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i6 = 2;
            c0053n3.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i6) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n3.y(null);
        }
        C0053n c0053n4 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.setInt", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i7 = 3;
            c0053n4.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i7) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n4.y(null);
        }
        C0053n c0053n5 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.setDouble", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i8 = 4;
            c0053n5.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i8) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n5.y(null);
        }
        C0053n c0053n6 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.setEncodedStringList", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i9 = 5;
            c0053n6.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i9) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n6.y(null);
        }
        C0053n c0053n7 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.setDeprecatedStringList", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i10 = 6;
            c0053n7.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i10) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n7.y(null);
        }
        C0053n c0053n8 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.clear", c0525b, dVarM, 5);
        if (c0524a != null) {
            final int i11 = 7;
            c0053n8.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i11) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        } else {
            c0053n8.y(null);
        }
        C0053n c0053n9 = new C0053n(fVar, "dev.flutter.pigeon.shared_preferences_android.SharedPreferencesApi.getAll", c0525b, dVarM, 5);
        if (c0524a == null) {
            c0053n9.y(null);
        } else {
            final int i12 = 8;
            c0053n9.y(new O2.b(c0524a) { // from class: l3.c

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ C0524a f5676b;

                {
                    this.f5676b = c0524a;
                }

                @Override // O2.b
                public final void d(Object obj, D2.v vVar) {
                    switch (i12) {
                        case 0:
                            C0524a c0524a2 = this.f5676b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                arrayList.add(0, Boolean.valueOf(c0524a2.f5672a.edit().remove((String) ((ArrayList) obj).get(0)).commit()));
                            } catch (Throwable th) {
                                arrayList = AbstractC0367g.P(th);
                            }
                            vVar.f(arrayList);
                            break;
                        case 1:
                            C0524a c0524a3 = this.f5676b;
                            ArrayList arrayList2 = new ArrayList();
                            ArrayList arrayList3 = (ArrayList) obj;
                            try {
                                arrayList2.add(0, Boolean.valueOf(c0524a3.f5672a.edit().putBoolean((String) arrayList3.get(0), ((Boolean) arrayList3.get(1)).booleanValue()).commit()));
                            } catch (Throwable th2) {
                                arrayList2 = AbstractC0367g.P(th2);
                            }
                            vVar.f(arrayList2);
                            break;
                        case 2:
                            C0524a c0524a4 = this.f5676b;
                            ArrayList arrayList4 = new ArrayList();
                            ArrayList arrayList5 = (ArrayList) obj;
                            try {
                                arrayList4.add(0, c0524a4.d((String) arrayList5.get(0), (String) arrayList5.get(1)));
                            } catch (Throwable th3) {
                                arrayList4 = AbstractC0367g.P(th3);
                            }
                            vVar.f(arrayList4);
                            break;
                        case 3:
                            C0524a c0524a5 = this.f5676b;
                            ArrayList arrayList6 = new ArrayList();
                            ArrayList arrayList7 = (ArrayList) obj;
                            try {
                                arrayList6.add(0, Boolean.valueOf(c0524a5.f5672a.edit().putLong((String) arrayList7.get(0), ((Long) arrayList7.get(1)).longValue()).commit()));
                            } catch (Throwable th4) {
                                arrayList6 = AbstractC0367g.P(th4);
                            }
                            vVar.f(arrayList6);
                            break;
                        case 4:
                            C0524a c0524a6 = this.f5676b;
                            ArrayList arrayList8 = new ArrayList();
                            ArrayList arrayList9 = (ArrayList) obj;
                            String str = (String) arrayList9.get(0);
                            Double d5 = (Double) arrayList9.get(1);
                            try {
                                c0524a6.getClass();
                                String string = Double.toString(d5.doubleValue());
                                arrayList8.add(0, Boolean.valueOf(c0524a6.f5672a.edit().putString(str, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu" + string).commit()));
                            } catch (Throwable th5) {
                                arrayList8 = AbstractC0367g.P(th5);
                            }
                            vVar.f(arrayList8);
                            break;
                        case 5:
                            C0524a c0524a7 = this.f5676b;
                            ArrayList arrayList10 = new ArrayList();
                            ArrayList arrayList11 = (ArrayList) obj;
                            try {
                                arrayList10.add(0, Boolean.valueOf(c0524a7.f5672a.edit().putString((String) arrayList11.get(0), (String) arrayList11.get(1)).commit()));
                            } catch (Throwable th6) {
                                arrayList10 = AbstractC0367g.P(th6);
                            }
                            vVar.f(arrayList10);
                            break;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            C0524a c0524a8 = this.f5676b;
                            ArrayList arrayList12 = new ArrayList();
                            ArrayList arrayList13 = (ArrayList) obj;
                            String str2 = (String) arrayList13.get(0);
                            List list = (List) arrayList13.get(1);
                            try {
                                arrayList12.add(0, Boolean.valueOf(c0524a8.f5672a.edit().putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + c0524a8.f5673b.e(list)).commit()));
                            } catch (Throwable th7) {
                                arrayList12 = AbstractC0367g.P(th7);
                            }
                            vVar.f(arrayList12);
                            break;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            C0524a c0524a9 = this.f5676b;
                            ArrayList arrayList14 = new ArrayList();
                            ArrayList arrayList15 = (ArrayList) obj;
                            try {
                                arrayList14.add(0, c0524a9.a((String) arrayList15.get(0), (List) arrayList15.get(1)));
                            } catch (Throwable th8) {
                                arrayList14 = AbstractC0367g.P(th8);
                            }
                            vVar.f(arrayList14);
                            break;
                        default:
                            C0524a c0524a10 = this.f5676b;
                            ArrayList arrayList16 = new ArrayList();
                            ArrayList arrayList17 = (ArrayList) obj;
                            try {
                                arrayList16.add(0, c0524a10.b((String) arrayList17.get(0), (List) arrayList17.get(1)));
                            } catch (Throwable th9) {
                                arrayList16 = AbstractC0367g.P(th9);
                            }
                            vVar.f(arrayList16);
                            break;
                    }
                }
            });
        }
    }

    public final Boolean a(String str, List list) {
        SharedPreferences.Editor editorEdit = this.f5672a.edit();
        Map<String, ?> all = this.f5672a.getAll();
        ArrayList arrayList = new ArrayList();
        for (String str2 : all.keySet()) {
            if (str2.startsWith(str) && (list == null || list.contains(str2))) {
                arrayList.add(str2);
            }
        }
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            editorEdit.remove((String) it.next());
        }
        return Boolean.valueOf(editorEdit.commit());
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    public final HashMap b(String str, List list) throws ClassNotFoundException, IOException {
        Object bigInteger;
        Object objValueOf;
        Set hashSet = list == null ? null : new HashSet(list);
        Map<String, ?> all = this.f5672a.getAll();
        HashMap map = new HashMap();
        for (String str2 : all.keySet()) {
            if (str2.startsWith(str) && (hashSet == null || hashSet.contains(str2))) {
                Object obj = all.get(str2);
                Objects.requireNonNull(obj);
                boolean z4 = obj instanceof String;
                X.N n4 = this.f5673b;
                if (z4) {
                    String str3 = (String) obj;
                    if (str3.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu")) {
                        objValueOf = obj;
                        if (!str3.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu!")) {
                            objValueOf = n4.d(str3.substring(40));
                        }
                    } else if (str3.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy")) {
                        bigInteger = new BigInteger(str3.substring(44), 36);
                        objValueOf = bigInteger;
                    } else {
                        objValueOf = obj;
                        if (str3.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu")) {
                            objValueOf = Double.valueOf(str3.substring(40));
                        }
                    }
                    map.put(str2, objValueOf);
                } else {
                    boolean z5 = obj instanceof Set;
                    objValueOf = obj;
                    if (z5) {
                        ArrayList arrayList = new ArrayList((Set) obj);
                        this.f5672a.edit().remove(str2).putString(str2, "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu" + n4.e(arrayList)).apply();
                        bigInteger = arrayList;
                        objValueOf = bigInteger;
                    }
                    map.put(str2, objValueOf);
                }
            }
        }
        return map;
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        O2.f fVar = (O2.f) c0747k.f6832c;
        this.f5672a = ((Context) c0747k.f6831b).getSharedPreferences("FlutterSharedPreferences", 0);
        try {
            e(fVar, this);
        } catch (Exception e) {
            Log.e("SharedPreferencesPlugin", "Received exception while setting up SharedPreferencesPlugin", e);
        }
    }

    public final Boolean d(String str, String str2) {
        if (str2.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu") || str2.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy") || str2.startsWith("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu")) {
            throw new RuntimeException("StorageError: This string cannot be stored as it clashes with special identifier prefixes");
        }
        return Boolean.valueOf(this.f5672a.edit().putString(str, str2).commit());
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        e((O2.f) c0747k.f6832c, null);
    }
}
