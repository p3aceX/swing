package k;

import D2.AbstractActivityC0029d;
import I.C0053n;
import O.RunnableC0093d;
import T2.C0160e;
import T2.C0161f;
import a.AbstractC0184a;
import android.content.Context;
import android.content.SharedPreferences;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.os.Handler;
import android.os.Looper;
import android.preference.PreferenceManager;
import android.util.Log;
import android.util.Range;
import b3.C0247a;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import e3.C0397a;
import f3.C0403a;
import h3.C0415a;
import java.io.ByteArrayInputStream;
import java.io.CharConversionException;
import java.io.File;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.security.KeyStoreException;
import java.security.ProviderException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;
import k.s0;
import u1.C0690c;
import x3.AbstractC0728h;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class s0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Object f5451a = null;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f5452b = null;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Object f5453c = null;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Object f5454d = null;
    public Object e = null;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public Object f5455f = null;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public Object f5456g;

    public static void f(Exception exc, T2.t tVar) {
        if (exc instanceof CameraAccessException) {
            tVar.a(new T2.v(null, "CameraAccess", exc.getMessage()));
        } else {
            tVar.a(new T2.v(null, "error", exc.getMessage()));
        }
    }

    public static void g(Exception exc, T2.J j4) {
        if (exc instanceof CameraAccessException) {
            j4.a(new T2.v(null, "CameraAccess", exc.getMessage()));
        } else {
            j4.a(new T2.v(null, "error", exc.getMessage()));
        }
    }

    public static byte[] j(Context context, String str, String str2) throws CharConversionException {
        if (str == null) {
            throw new IllegalArgumentException("keysetName cannot be null");
        }
        Context applicationContext = context.getApplicationContext();
        try {
            String string = (str2 == null ? PreferenceManager.getDefaultSharedPreferences(applicationContext) : applicationContext.getSharedPreferences(str2, 0)).getString(str, null);
            if (string == null) {
                return null;
            }
            return e1.k.m(string);
        } catch (ClassCastException | IllegalArgumentException unused) {
            throw new CharConversionException(com.google.crypto.tink.shaded.protobuf.S.g("can't read keyset; the pref value ", str, " is not a valid hex string"));
        }
    }

    public static R0.f k(byte[] bArr) throws IOException {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bArr);
        try {
            d1.g0 g0VarD = d1.g0.D(byteArrayInputStream, C0309n.a());
            byteArrayInputStream.close();
            return new R0.f((d1.d0) ((d1.g0) C0747k.D(g0VarD).f6831b).v(), 3);
        } catch (Throwable th) {
            byteArrayInputStream.close();
            throw th;
        }
    }

    public static void n(O2.f fVar, final s0 s0Var) {
        T2.w wVar = T2.w.f2004d;
        Object obj = null;
        C0053n c0053n = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.getAvailableCameras", wVar, obj, 5);
        if (s0Var != null) {
            final int i4 = 0;
            c0053n.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i4) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i5 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i5 = 2;
                                }
                                c0161f3.l(i5);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i6 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i6 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i6 = 4;
                                        }
                                    } else {
                                        i6 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i6;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i7 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i7 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i7 = 4;
                                    }
                                } else {
                                    i7 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i7);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i8 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i8 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i8;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n.y(null);
        }
        C0053n c0053n2 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.create", wVar, obj, 5);
        if (s0Var != null) {
            final int i5 = 2;
            c0053n2.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i5) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i6 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i6 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i6 = 4;
                                        }
                                    } else {
                                        i6 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i6;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i7 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i7 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i7 = 4;
                                    }
                                } else {
                                    i7 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i7);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i8 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i8 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i8;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n2.y(null);
        }
        C0053n c0053n3 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.initialize", wVar, obj, 5);
        if (s0Var != null) {
            final int i6 = 12;
            c0053n3.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i6) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i7 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i7 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i7 = 4;
                                    }
                                } else {
                                    i7 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i7);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i8 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i8 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i8;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n3.y(null);
        }
        C0053n c0053n4 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.dispose", wVar, obj, 5);
        if (s0Var != null) {
            final int i7 = 13;
            c0053n4.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i7) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i8 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i8 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i8;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n4.y(null);
        }
        C0053n c0053n5 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.lockCaptureOrientation", wVar, obj, 5);
        if (s0Var != null) {
            final int i8 = 14;
            c0053n5.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i8) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n5.y(null);
        }
        C0053n c0053n6 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.unlockCaptureOrientation", wVar, obj, 5);
        if (s0Var != null) {
            final int i9 = 15;
            c0053n6.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i9) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n6.y(null);
        }
        C0053n c0053n7 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.takePicture", wVar, obj, 5);
        if (s0Var != null) {
            final int i10 = 16;
            c0053n7.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i10) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n7.y(null);
        }
        C0053n c0053n8 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.startVideoRecording", wVar, obj, 5);
        if (s0Var != null) {
            final int i11 = 17;
            c0053n8.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i11) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n8.y(null);
        }
        C0053n c0053n9 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.stopVideoRecording", wVar, obj, 5);
        if (s0Var != null) {
            final int i12 = 18;
            c0053n9.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i12) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n9.y(null);
        }
        C0053n c0053n10 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.pauseVideoRecording", wVar, obj, 5);
        if (s0Var != null) {
            final int i13 = 19;
            c0053n10.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i13) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n10.y(null);
        }
        C0053n c0053n11 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.resumeVideoRecording", wVar, obj, 5);
        if (s0Var != null) {
            final int i14 = 11;
            c0053n11.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i14) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n11.y(null);
        }
        C0053n c0053n12 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.startImageStream", wVar, obj, 5);
        if (s0Var != null) {
            final int i15 = 20;
            c0053n12.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i15) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n12.y(null);
        }
        C0053n c0053n13 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.stopImageStream", wVar, obj, 5);
        if (s0Var != null) {
            final int i16 = 21;
            c0053n13.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i16) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n13.y(null);
        }
        C0053n c0053n14 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setFlashMode", wVar, obj, 5);
        if (s0Var != null) {
            final int i17 = 22;
            c0053n14.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i17) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n14.y(null);
        }
        C0053n c0053n15 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setExposureMode", wVar, obj, 5);
        if (s0Var != null) {
            final int i18 = 23;
            c0053n15.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i18) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n15.y(null);
        }
        T2.w wVar2 = T2.w.f2004d;
        C0053n c0053n16 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setExposurePoint", wVar, obj, 5);
        if (s0Var != null) {
            final int i19 = 24;
            c0053n16.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i19) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n16.y(null);
        }
        T2.w wVar3 = T2.w.f2004d;
        C0053n c0053n17 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.getMinExposureOffset", wVar, obj, 5);
        if (s0Var != null) {
            final int i20 = 25;
            c0053n17.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i20) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n17.y(null);
        }
        T2.w wVar4 = T2.w.f2004d;
        C0053n c0053n18 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.getMaxExposureOffset", wVar, obj, 5);
        if (s0Var != null) {
            final int i21 = 26;
            c0053n18.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i21) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n18.y(null);
        }
        T2.w wVar5 = T2.w.f2004d;
        C0053n c0053n19 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.getExposureOffsetStepSize", wVar, obj, 5);
        if (s0Var != null) {
            final int i22 = 27;
            c0053n19.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i22) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n19.y(null);
        }
        T2.w wVar6 = T2.w.f2004d;
        C0053n c0053n20 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setExposureOffset", wVar, obj, 5);
        if (s0Var != null) {
            final int i23 = 1;
            c0053n20.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i23) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n20.y(null);
        }
        T2.w wVar7 = T2.w.f2004d;
        C0053n c0053n21 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setFocusMode", wVar, obj, 5);
        if (s0Var != null) {
            final int i24 = 3;
            c0053n21.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i24) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n21.y(null);
        }
        T2.w wVar8 = T2.w.f2004d;
        C0053n c0053n22 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setFocusPoint", wVar, obj, 5);
        if (s0Var != null) {
            final int i25 = 4;
            c0053n22.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i25) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n22.y(null);
        }
        T2.w wVar9 = T2.w.f2004d;
        C0053n c0053n23 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.getMaxZoomLevel", wVar, obj, 5);
        if (s0Var != null) {
            final int i26 = 5;
            c0053n23.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i26) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n23.y(null);
        }
        T2.w wVar10 = T2.w.f2004d;
        C0053n c0053n24 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.getMinZoomLevel", wVar, obj, 5);
        if (s0Var != null) {
            final int i27 = 6;
            c0053n24.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i27) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n24.y(null);
        }
        T2.w wVar11 = T2.w.f2004d;
        C0053n c0053n25 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setZoomLevel", wVar, obj, 5);
        if (s0Var != null) {
            final int i28 = 7;
            c0053n25.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i28) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n25.y(null);
        }
        T2.w wVar12 = T2.w.f2004d;
        C0053n c0053n26 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.pausePreview", wVar, obj, 5);
        if (s0Var != null) {
            final int i29 = 8;
            c0053n26.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i29) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n26.y(null);
        }
        T2.w wVar13 = T2.w.f2004d;
        C0053n c0053n27 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.resumePreview", wVar, obj, 5);
        if (s0Var != null) {
            final int i30 = 9;
            c0053n27.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i30) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        } else {
            c0053n27.y(null);
        }
        T2.w wVar14 = T2.w.f2004d;
        C0053n c0053n28 = new C0053n(fVar, "dev.flutter.pigeon.camera_android.CameraApi.setDescriptionWhileRecording", wVar, obj, 5);
        if (s0Var == null) {
            c0053n28.y(null);
        } else {
            final int i31 = 10;
            c0053n28.y(new O2.b(s0Var) { // from class: T2.s

                /* JADX INFO: renamed from: b, reason: collision with root package name */
                public final /* synthetic */ s0 f1996b;

                {
                    this.f1996b = s0Var;
                }

                private final void a(Object obj2, D2.v vVar) {
                    ArrayList arrayList = new ArrayList();
                    G g4 = (G) ((ArrayList) obj2).get(0);
                    t tVar = new t(arrayList, vVar, 4);
                    s0 s0Var2 = this.f1996b;
                    s0Var2.getClass();
                    try {
                        C0161f c0161f = (C0161f) s0Var2.f5456g;
                        D2.v vVar2 = null;
                        D2.v vVar3 = g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false);
                        Y2.a aVarB = c0161f.f1940a.b();
                        if (vVar3 != null && ((Double) vVar3.f260b) != null && ((Double) vVar3.f261c) != null) {
                            vVar2 = vVar3;
                        }
                        aVarB.f2521c = vVar2;
                        aVarB.b();
                        aVarB.a(c0161f.f1957s);
                        c0161f.h(new F1.a(tVar, 9), new D2.u(tVar, 7));
                    } catch (Exception e) {
                        s0.g(e, tVar);
                    }
                }

                private final void b(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getLower()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                private final void c(Object obj2, D2.v vVar) {
                    s0 s0Var2 = this.f1996b;
                    ArrayList arrayList = new ArrayList();
                    try {
                        X2.a aVarA = ((C0161f) s0Var2.f5456g).f1940a.a();
                        arrayList.add(0, Double.valueOf(aVarA.b() * (((Range) ((CameraCharacteristics) aVarA.f2100a.f260b).get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE)) == null ? 0.0d : ((Integer) r1.getUpper()).intValue())));
                    } catch (Throwable th) {
                        arrayList = H0.a.k0(th);
                    }
                    vVar.f(arrayList);
                }

                @Override // O2.b
                public final void d(Object obj2, D2.v vVar) {
                    List listH;
                    switch (i31) {
                        case 0:
                            s0 s0Var2 = this.f1996b;
                            ArrayList arrayList = new ArrayList();
                            try {
                                AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) s0Var2.f5451a;
                                if (abstractActivityC0029d == null) {
                                    listH = Collections.EMPTY_LIST;
                                } else {
                                    try {
                                        listH = AbstractC0184a.H(abstractActivityC0029d);
                                    } catch (CameraAccessException e) {
                                        throw new RuntimeException(e);
                                    }
                                }
                                arrayList.add(0, listH);
                                break;
                            } catch (Throwable th) {
                                arrayList = H0.a.k0(th);
                            }
                            vVar.f(arrayList);
                            return;
                        case 1:
                            ArrayList arrayList2 = new ArrayList();
                            Double d5 = (Double) ((ArrayList) obj2).get(0);
                            t tVar = new t(arrayList2, vVar, 5);
                            s0 s0Var3 = this.f1996b;
                            s0Var3.getClass();
                            try {
                                C0161f c0161f = (C0161f) s0Var3.f5456g;
                                double dDoubleValue = d5.doubleValue();
                                X2.a aVarA = c0161f.f1940a.a();
                                aVarA.f2413b = dDoubleValue / aVarA.b();
                                aVarA.a(c0161f.f1957s);
                                c0161f.h(new RunnableC0093d(2, tVar, aVarA), new D2.u(tVar, 4));
                                return;
                            } catch (Exception e4) {
                                s0.f(e4, tVar);
                                return;
                            }
                        case 2:
                            ArrayList arrayList3 = new ArrayList();
                            ArrayList arrayList4 = (ArrayList) obj2;
                            String str = (String) arrayList4.get(0);
                            F f4 = (F) arrayList4.get(1);
                            t tVar2 = new t(arrayList3, vVar, 0);
                            s0 s0Var4 = this.f1996b;
                            C0161f c0161f2 = (C0161f) s0Var4.f5456g;
                            if (c0161f2 != null) {
                                c0161f2.a();
                            }
                            boolean zBooleanValue = f4.e.booleanValue();
                            C0162g c0162g = new C0162g(s0Var4, tVar2, str, f4);
                            C0166k c0166k = (C0166k) s0Var4.f5453c;
                            if (c0166k.f1977a) {
                                c0162g.a("CameraPermissionsRequestOngoing", "Another request is ongoing and multiple requests cannot be handled at once.");
                                return;
                            }
                            AbstractActivityC0029d abstractActivityC0029d2 = (AbstractActivityC0029d) s0Var4.f5451a;
                            if (r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.CAMERA") == 0 && (!zBooleanValue || r.h.checkSelfPermission(abstractActivityC0029d2, "android.permission.RECORD_AUDIO") == 0)) {
                                c0162g.a(null, null);
                                return;
                            }
                            ((HashSet) ((Y0.n) ((D2.u) s0Var4.f5454d).f257b).f2489b).add(new C0165j(new C0164i(c0166k, c0162g)));
                            c0166k.f1977a = true;
                            q.e.a(abstractActivityC0029d2, zBooleanValue ? new String[]{"android.permission.CAMERA", "android.permission.RECORD_AUDIO"} : new String[]{"android.permission.CAMERA"}, 9796);
                            return;
                        case 3:
                            s0 s0Var5 = this.f1996b;
                            ArrayList arrayList5 = new ArrayList();
                            D d6 = (D) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f3 = (C0161f) s0Var5.f5456g;
                                int iOrdinal = d6.ordinal();
                                int i52 = 1;
                                if (iOrdinal != 0) {
                                    if (iOrdinal != 1) {
                                        throw new IllegalStateException("Unreachable code");
                                    }
                                    i52 = 2;
                                }
                                c0161f3.l(i52);
                                arrayList5.add(0, null);
                            } catch (Throwable th2) {
                                arrayList5 = H0.a.k0(th2);
                            }
                            vVar.f(arrayList5);
                            return;
                        case 4:
                            ArrayList arrayList6 = new ArrayList();
                            G g4 = (G) ((ArrayList) obj2).get(0);
                            t tVar3 = new t(arrayList6, vVar, 6);
                            s0 s0Var6 = this.f1996b;
                            s0Var6.getClass();
                            try {
                                ((C0161f) s0Var6.f5456g).m(tVar3, g4 == null ? null : new D2.v(g4.f1898a, g4.f1899b, 26, false));
                                return;
                            } catch (Exception e5) {
                                s0.g(e5, tVar3);
                                return;
                            }
                        case 5:
                            s0 s0Var7 = this.f1996b;
                            ArrayList arrayList7 = new ArrayList();
                            try {
                                arrayList7.add(0, Double.valueOf(((C0161f) s0Var7.f5456g).f1940a.f().f4293f.floatValue()));
                                break;
                            } catch (Throwable th3) {
                                arrayList7 = H0.a.k0(th3);
                            }
                            vVar.f(arrayList7);
                            return;
                        case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                            s0 s0Var8 = this.f1996b;
                            ArrayList arrayList8 = new ArrayList();
                            try {
                                arrayList8.add(0, Double.valueOf(((C0161f) s0Var8.f5456g).f1940a.f().e.floatValue()));
                                break;
                            } catch (Throwable th4) {
                                arrayList8 = H0.a.k0(th4);
                            }
                            vVar.f(arrayList8);
                            return;
                        case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                            ArrayList arrayList9 = new ArrayList();
                            Double d7 = (Double) ((ArrayList) obj2).get(0);
                            t tVar4 = new t(arrayList9, vVar, 7);
                            C0161f c0161f4 = (C0161f) this.f1996b.f5456g;
                            float fFloatValue = d7.floatValue();
                            C0403a c0403aF = c0161f4.f1940a.f();
                            Float f5 = c0403aF.f4293f;
                            float fFloatValue2 = f5.floatValue();
                            Float f6 = c0403aF.e;
                            float fFloatValue3 = f6.floatValue();
                            if (fFloatValue > fFloatValue2 || fFloatValue < fFloatValue3) {
                                tVar4.a(new v(null, "ZOOM_ERROR", String.format(Locale.ENGLISH, "Zoom level out of bounds (zoom level should be between %f and %f).", f6, f5)));
                                return;
                            }
                            c0403aF.f4292d = Float.valueOf(fFloatValue);
                            c0403aF.a(c0161f4.f1957s);
                            c0161f4.h(new F1.a(tVar4, 10), new D2.u(tVar4, 8));
                            return;
                        case K.k.BYTES_FIELD_NUMBER /* 8 */:
                            s0 s0Var9 = this.f1996b;
                            ArrayList arrayList10 = new ArrayList();
                            try {
                                s0Var9.getClass();
                                try {
                                    C0161f c0161f5 = (C0161f) s0Var9.f5456g;
                                    if (!c0161f5.v) {
                                        c0161f5.v = true;
                                        CameraCaptureSession cameraCaptureSession = c0161f5.f1954p;
                                        if (cameraCaptureSession != null) {
                                            cameraCaptureSession.stopRepeating();
                                        }
                                    }
                                    arrayList10.add(0, null);
                                } catch (CameraAccessException e6) {
                                    throw new v(null, "CameraAccessException", e6.getMessage());
                                }
                                break;
                            } catch (Throwable th5) {
                                arrayList10 = H0.a.k0(th5);
                            }
                            vVar.f(arrayList10);
                            return;
                        case 9:
                            s0 s0Var10 = this.f1996b;
                            ArrayList arrayList11 = new ArrayList();
                            try {
                                C0161f c0161f6 = (C0161f) s0Var10.f5456g;
                                c0161f6.v = false;
                                c0161f6.h(null, new C0156a(c0161f6, 0));
                                arrayList11.add(0, null);
                                break;
                            } catch (Throwable th6) {
                                arrayList11 = H0.a.k0(th6);
                            }
                            vVar.f(arrayList11);
                            return;
                        case 10:
                            s0 s0Var11 = this.f1996b;
                            ArrayList arrayList12 = new ArrayList();
                            String str2 = (String) ((ArrayList) obj2).get(0);
                            try {
                                s0Var11.getClass();
                            } catch (Throwable th7) {
                                arrayList12 = H0.a.k0(th7);
                            }
                            try {
                                ((C0161f) s0Var11.f5456g).j(new D2.v(str2, (CameraManager) ((AbstractActivityC0029d) s0Var11.f5451a).getSystemService("camera")));
                                arrayList12.add(0, null);
                                vVar.f(arrayList12);
                                return;
                            } catch (CameraAccessException e7) {
                                throw new v(null, "CameraAccessException", e7.getMessage());
                            }
                        case ModuleDescriptor.MODULE_VERSION /* 11 */:
                            s0 s0Var12 = this.f1996b;
                            ArrayList arrayList13 = new ArrayList();
                            try {
                                C0161f c0161f7 = (C0161f) s0Var12.f5456g;
                                if (c0161f7.f1959u) {
                                    try {
                                        c0161f7.f1958t.resume();
                                    } catch (IllegalStateException e8) {
                                        throw new v(null, "videoRecordingFailed", e8.getMessage());
                                    }
                                }
                                arrayList13.add(0, null);
                                break;
                            } catch (Throwable th8) {
                                arrayList13 = H0.a.k0(th8);
                            }
                            vVar.f(arrayList13);
                            return;
                        case 12:
                            s0 s0Var13 = this.f1996b;
                            ArrayList arrayList14 = new ArrayList();
                            try {
                                s0Var13.h((E) ((ArrayList) obj2).get(0));
                                arrayList14.add(0, null);
                                break;
                            } catch (Throwable th9) {
                                arrayList14 = H0.a.k0(th9);
                            }
                            vVar.f(arrayList14);
                            return;
                        case 13:
                            s0 s0Var14 = this.f1996b;
                            ArrayList arrayList15 = new ArrayList();
                            try {
                                C0161f c0161f8 = (C0161f) s0Var14.f5456g;
                                if (c0161f8 != null) {
                                    Log.i("Camera", "dispose");
                                    c0161f8.a();
                                    c0161f8.e.release();
                                    e3.b bVar = c0161f8.f1940a.e().f4241c;
                                    C0397a c0397a = bVar.f4239f;
                                    if (c0397a != null) {
                                        bVar.f4235a.unregisterReceiver(c0397a);
                                        bVar.f4239f = null;
                                    }
                                }
                                arrayList15.add(0, null);
                                break;
                            } catch (Throwable th10) {
                                arrayList15 = H0.a.k0(th10);
                            }
                            vVar.f(arrayList15);
                            return;
                        case 14:
                            s0 s0Var15 = this.f1996b;
                            ArrayList arrayList16 = new ArrayList();
                            A a5 = (A) ((ArrayList) obj2).get(0);
                            try {
                                C0161f c0161f9 = (C0161f) s0Var15.f5456g;
                                int iOrdinal2 = a5.ordinal();
                                int i62 = 1;
                                if (iOrdinal2 != 0) {
                                    if (iOrdinal2 != 1) {
                                        i62 = 3;
                                        if (iOrdinal2 != 2) {
                                            if (iOrdinal2 != 3) {
                                                throw new IllegalStateException("Unreachable code");
                                            }
                                            i62 = 4;
                                        }
                                    } else {
                                        i62 = 2;
                                    }
                                }
                                c0161f9.f1940a.e().f4242d = i62;
                                arrayList16.add(0, null);
                            } catch (Throwable th11) {
                                arrayList16 = H0.a.k0(th11);
                            }
                            vVar.f(arrayList16);
                            return;
                        case 15:
                            s0 s0Var16 = this.f1996b;
                            ArrayList arrayList17 = new ArrayList();
                            try {
                                ((C0161f) s0Var16.f5456g).f1940a.e().f4242d = 0;
                                arrayList17.add(0, null);
                                break;
                            } catch (Throwable th12) {
                                arrayList17 = H0.a.k0(th12);
                            }
                            vVar.f(arrayList17);
                            return;
                        case 16:
                            t tVar5 = new t(new ArrayList(), vVar, 1);
                            C0161f c0161f10 = (C0161f) this.f1996b.f5456g;
                            C0163h c0163h = c0161f10.f1950l;
                            if (c0163h.f1969b != 1) {
                                tVar5.a(new v(null, "captureAlreadyActive", "Picture is currently already being captured"));
                                return;
                            }
                            c0161f10.f1963z = tVar5;
                            try {
                                c0161f10.f1960w = File.createTempFile("CAP", ".jpg", c0161f10.f1945g.getCacheDir());
                                com.google.android.gms.common.internal.r rVar = c0161f10.f1961x;
                                rVar.getClass();
                                rVar.f3597b = new C0415a();
                                rVar.f3598c = new C0415a();
                                c0161f10.f1955q.setOnImageAvailableListener(c0161f10, c0161f10.f1951m);
                                V2.a aVar = (V2.a) c0161f10.f1940a.f378a.get("AUTO_FOCUS");
                                if (!aVar.b() || aVar.f2209b != 1) {
                                    c0161f10.i();
                                    return;
                                }
                                Log.i("Camera", "runPictureAutoFocus");
                                c0163h.f1969b = 2;
                                c0161f10.d();
                                return;
                            } catch (IOException | SecurityException e9) {
                                c0161f10.f1946h.B(c0161f10.f1963z, "cannotCreateFile", e9.getMessage());
                                return;
                            }
                        case 17:
                            s0 s0Var17 = this.f1996b;
                            ArrayList arrayList18 = new ArrayList();
                            try {
                                s0Var17.o((Boolean) ((ArrayList) obj2).get(0));
                                arrayList18.add(0, null);
                                break;
                            } catch (Throwable th13) {
                                arrayList18 = H0.a.k0(th13);
                            }
                            vVar.f(arrayList18);
                            return;
                        case 18:
                            s0 s0Var18 = this.f1996b;
                            ArrayList arrayList19 = new ArrayList();
                            try {
                                arrayList19.add(0, s0Var18.p());
                                break;
                            } catch (Throwable th14) {
                                arrayList19 = H0.a.k0(th14);
                            }
                            vVar.f(arrayList19);
                            return;
                        case 19:
                            s0 s0Var19 = this.f1996b;
                            ArrayList arrayList20 = new ArrayList();
                            try {
                                C0161f c0161f11 = (C0161f) s0Var19.f5456g;
                                if (c0161f11.f1959u) {
                                    try {
                                        c0161f11.f1958t.pause();
                                    } catch (IllegalStateException e10) {
                                        throw new v(null, "videoRecordingFailed", e10.getMessage());
                                    }
                                }
                                arrayList20.add(0, null);
                                break;
                            } catch (Throwable th15) {
                                arrayList20 = H0.a.k0(th15);
                            }
                            vVar.f(arrayList20);
                            return;
                        case 20:
                            s0 s0Var20 = this.f1996b;
                            ArrayList arrayList21 = new ArrayList();
                            try {
                                s0Var20.getClass();
                            } catch (Throwable th16) {
                                arrayList21 = H0.a.k0(th16);
                            }
                            try {
                                C0161f c0161f12 = (C0161f) s0Var20.f5456g;
                                C0747k c0747k = (C0747k) s0Var20.f5455f;
                                c0161f12.getClass();
                                c0747k.Z(new B.k(c0161f12, 16));
                                c0161f12.o(false, true);
                                Log.i("Camera", "startPreviewWithImageStream");
                                arrayList21.add(0, null);
                                vVar.f(arrayList21);
                                return;
                            } catch (CameraAccessException e11) {
                                throw new v(null, "CameraAccessException", e11.getMessage());
                            }
                        case 21:
                            s0 s0Var21 = this.f1996b;
                            ArrayList arrayList22 = new ArrayList();
                            try {
                                s0Var21.getClass();
                                try {
                                    ((C0161f) s0Var21.f5456g).p(null);
                                    arrayList22.add(0, null);
                                } catch (Exception e12) {
                                    throw new v(null, e12.getClass().getName(), e12.getMessage());
                                }
                            } catch (Throwable th17) {
                                arrayList22 = H0.a.k0(th17);
                            }
                            vVar.f(arrayList22);
                            return;
                        case 22:
                            ArrayList arrayList23 = new ArrayList();
                            C c5 = (C) ((ArrayList) obj2).get(0);
                            t tVar6 = new t(arrayList23, vVar, 2);
                            s0 s0Var22 = this.f1996b;
                            s0Var22.getClass();
                            int iOrdinal3 = c5.ordinal();
                            int i72 = 1;
                            if (iOrdinal3 != 0) {
                                if (iOrdinal3 != 1) {
                                    i72 = 3;
                                    if (iOrdinal3 != 2) {
                                        if (iOrdinal3 != 3) {
                                            throw new IllegalStateException("Unreachable code");
                                        }
                                        i72 = 4;
                                    }
                                } else {
                                    i72 = 2;
                                }
                            }
                            try {
                                ((C0161f) s0Var22.f5456g).k(tVar6, i72);
                                return;
                            } catch (Exception e13) {
                                s0.g(e13, tVar6);
                                return;
                            }
                        case 23:
                            ArrayList arrayList24 = new ArrayList();
                            B b5 = (B) ((ArrayList) obj2).get(0);
                            t tVar7 = new t(arrayList24, vVar, 3);
                            s0 s0Var23 = this.f1996b;
                            s0Var23.getClass();
                            int iOrdinal4 = b5.ordinal();
                            int i82 = 1;
                            if (iOrdinal4 != 0) {
                                if (iOrdinal4 != 1) {
                                    throw new IllegalStateException("Unreachable code");
                                }
                                i82 = 2;
                            }
                            try {
                                C0161f c0161f13 = (C0161f) s0Var23.f5456g;
                                W2.a aVar2 = (W2.a) c0161f13.f1940a.f378a.get("EXPOSURE_LOCK");
                                aVar2.f2272b = i82;
                                aVar2.a(c0161f13.f1957s);
                                c0161f13.h(new F1.a(tVar7, 7), new D2.u(tVar7, 5));
                                return;
                            } catch (Exception e14) {
                                s0.g(e14, tVar7);
                                return;
                            }
                        case 24:
                            a(obj2, vVar);
                            return;
                        case 25:
                            b(obj2, vVar);
                            return;
                        case 26:
                            c(obj2, vVar);
                            return;
                        default:
                            s0 s0Var24 = this.f1996b;
                            ArrayList arrayList25 = new ArrayList();
                            try {
                                arrayList25.add(0, Double.valueOf(((C0161f) s0Var24.f5456g).f1940a.a().b()));
                                break;
                            } catch (Throwable th18) {
                                arrayList25 = H0.a.k0(th18);
                            }
                            vVar.f(arrayList25);
                            return;
                    }
                }
            });
        }
    }

    public synchronized X0.a a() {
        X0.a aVar;
        try {
            if (((String) this.f5452b) == null) {
                throw new IllegalArgumentException("keysetName cannot be null");
            }
            synchronized (X0.a.f2381b) {
                try {
                    byte[] bArrJ = j((Context) this.f5451a, (String) this.f5452b, (String) this.f5453c);
                    if (bArrJ == null) {
                        if (((String) this.f5454d) != null) {
                            this.e = m();
                        }
                        this.f5456g = b();
                    } else if (((String) this.f5454d) != null) {
                        this.f5456g = l(bArrJ);
                    } else {
                        this.f5456g = k(bArrJ);
                    }
                    aVar = new X0.a(this);
                } finally {
                }
            }
        } catch (Throwable th) {
            throw th;
        }
        return aVar;
    }

    public R0.f b() throws GeneralSecurityException, IOException {
        if (((R0.g) this.f5455f) == null) {
            throw new GeneralSecurityException("cannot read or generate keyset");
        }
        R0.f fVar = new R0.f(d1.g0.C(), 3);
        R0.g gVar = (R0.g) this.f5455f;
        synchronized (fVar) {
            fVar.a(gVar.f1687a);
        }
        int iA = R0.p.a((d1.g0) fVar.c().f6831b).y().A();
        synchronized (fVar) {
            for (int i4 = 0; i4 < ((d1.g0) ((d1.d0) fVar.f1686b).f3838b).z(); i4++) {
                try {
                    d1.f0 f0VarY = ((d1.g0) ((d1.d0) fVar.f1686b).f3838b).y(i4);
                    if (f0VarY.B() == iA) {
                        if (!f0VarY.D().equals(d1.Z.ENABLED)) {
                            throw new GeneralSecurityException("cannot set key as primary because it's not enabled: " + iA);
                        }
                        d1.d0 d0Var = (d1.d0) fVar.f1686b;
                        d0Var.e();
                        d1.g0.w((d1.g0) d0Var.f3838b, iA);
                    }
                } catch (Throwable th) {
                    throw th;
                }
            }
            throw new GeneralSecurityException("key not found: " + iA);
        }
        Context context = (Context) this.f5451a;
        String str = (String) this.f5452b;
        String str2 = (String) this.f5453c;
        if (str == null) {
            throw new IllegalArgumentException("keysetName cannot be null");
        }
        Context applicationContext = context.getApplicationContext();
        SharedPreferences.Editor editorEdit = str2 == null ? PreferenceManager.getDefaultSharedPreferences(applicationContext).edit() : applicationContext.getSharedPreferences(str2, 0).edit();
        if (((X0.b) this.e) != null) {
            C0747k c0747kC = fVar.c();
            X0.b bVar = (X0.b) this.e;
            byte[] bArr = new byte[0];
            d1.g0 g0Var = (d1.g0) c0747kC.f6831b;
            byte[] bArrA = bVar.a(g0Var.e(), bArr);
            try {
                if (!d1.g0.E(bVar.b(bArrA, bArr), C0309n.a()).equals(g0Var)) {
                    throw new GeneralSecurityException("cannot encrypt keyset");
                }
                d1.M mZ = d1.N.z();
                C0302g c0302gH = AbstractC0303h.h(bArrA, 0, bArrA.length);
                mZ.e();
                d1.N.w((d1.N) mZ.f3838b, c0302gH);
                d1.k0 k0VarA = R0.p.a(g0Var);
                mZ.e();
                d1.N.x((d1.N) mZ.f3838b, k0VarA);
                if (!editorEdit.putString(str, e1.k.p(((d1.N) mZ.b()).e())).commit()) {
                    throw new IOException("Failed to write to SharedPreferences");
                }
            } catch (com.google.crypto.tink.shaded.protobuf.B unused) {
                throw new GeneralSecurityException("invalid keyset, corrupted key material");
            }
        } else if (!editorEdit.putString(str, e1.k.p(((d1.g0) fVar.c().f6831b).e())).commit()) {
            throw new IOException("Failed to write to SharedPreferences");
        }
        return fVar;
    }

    public LinkedHashMap c() {
        String str = (String) this.f5455f;
        Iterable<String> iterableD0 = str != null ? P3.m.D0(str, new String[]{"&"}) : x3.p.f6784a;
        LinkedHashMap linkedHashMap = new LinkedHashMap();
        for (String str2 : iterableD0) {
            Pattern patternCompile = Pattern.compile("=");
            J3.i.d(patternCompile, "compile(...)");
            J3.i.e(str2, "<this>");
            P3.m.B0(2);
            String[] strArrSplit = patternCompile.split(str2, 2);
            J3.i.d(strArrSplit, "split(...)");
            List listAsList = Arrays.asList(strArrSplit);
            J3.i.d(listAsList, "asList(...)");
            if (listAsList.size() == 2) {
                linkedHashMap.put(listAsList.get(0), listAsList.get(1));
            }
        }
        return linkedHashMap;
    }

    public String d() {
        LinkedHashMap linkedHashMapC = c();
        ArrayList arrayList = new ArrayList(linkedHashMapC.size());
        for (Map.Entry entry : linkedHashMapC.entrySet()) {
            arrayList.add(((String) entry.getKey()) + "=" + ((String) entry.getValue()));
        }
        String strA0 = AbstractC0728h.a0(arrayList, "&", null, null, null, 62);
        String strE = e();
        if (strE.length() == 0 && (strE = (String) this.f5455f) == null) {
            strE = "";
        }
        List listE0 = P3.m.E0(P3.m.A0(strE, strA0, ""), new char[]{'/'});
        ArrayList arrayList2 = new ArrayList();
        for (Object obj : listE0) {
            if (((String) obj).length() > 0) {
                arrayList2.add(obj);
            }
        }
        int size = arrayList2.size();
        return size != 0 ? (size == 1 || size == 2) ? (String) arrayList2.get(0) : AbstractC0728h.a0(arrayList2.subList(0, 2), "/", null, null, null, 62) : "";
    }

    public String e() {
        String str = (String) this.f5455f;
        String str2 = "";
        String strZ0 = P3.m.z0(((String) this.e) + (str == null ? "" : "?".concat(str)), "?");
        if (strZ0.length() != 0) {
            return strZ0;
        }
        Integer num = (Integer) this.f5454d;
        if (num != null) {
            str2 = ":" + num;
        }
        StringBuilder sb = new StringBuilder();
        sb.append((String) this.f5452b);
        sb.append("://");
        return P3.m.z0(P3.m.z0((String) this.f5451a, com.google.crypto.tink.shaded.protobuf.S.h(sb, (String) this.f5453c, str2)), "/");
    }

    public void h(T2.E e) {
        int i4;
        C0161f c0161f = (C0161f) this.f5456g;
        if (c0161f == null) {
            throw new T2.v(null, "cameraNotFound", "Camera not found. Please call the 'create' method before calling 'initialize'.");
        }
        try {
            int iOrdinal = e.ordinal();
            if (iOrdinal == 0) {
                i4 = 35;
            } else if (iOrdinal == 1) {
                i4 = 256;
            } else {
                if (iOrdinal != 2) {
                    throw new IllegalStateException("Unreachable code");
                }
                i4 = 17;
            }
            c0161f.f(i4);
        } catch (CameraAccessException e4) {
            throw new T2.v(null, "CameraAccessException", e4.getMessage());
        }
    }

    public Long i(String str, T2.F f4) {
        int i4;
        io.flutter.embedding.engine.renderer.g gVarE = ((io.flutter.embedding.engine.renderer.j) this.e).e();
        Handler handler = new Handler(Looper.getMainLooper());
        O2.f fVar = (O2.f) this.f5452b;
        C0690c c0690c = new C0690c(fVar, 19);
        long j4 = gVarE.f4509a;
        C0747k c0747k = new C0747k(handler, c0690c, new D2.v(fVar, String.valueOf(j4)), 17);
        D2.v vVar = new D2.v(str, (CameraManager) ((AbstractActivityC0029d) this.f5451a).getSystemService("camera"));
        Long l2 = f4.f1895b;
        Integer numValueOf = l2 == null ? null : Integer.valueOf(l2.intValue());
        Long l4 = f4.f1896c;
        Integer numValueOf2 = l4 == null ? null : Integer.valueOf(l4.intValue());
        Long l5 = f4.f1897d;
        Integer numValueOf3 = l5 != null ? Integer.valueOf(l5.intValue()) : null;
        int iOrdinal = f4.f1894a.ordinal();
        int i5 = 1;
        if (iOrdinal != 0) {
            int i6 = 2;
            if (iOrdinal != 1) {
                i5 = 3;
                if (iOrdinal != 2) {
                    i6 = 4;
                    if (iOrdinal != 3) {
                        i5 = 5;
                        if (iOrdinal != 4) {
                            if (iOrdinal != 5) {
                                throw new IllegalStateException("Unreachable code");
                            }
                            i5 = 6;
                        }
                    }
                }
                i4 = i5;
            }
            i4 = i6;
        } else {
            i4 = i5;
        }
        this.f5456g = new C0161f((AbstractActivityC0029d) this.f5451a, gVarE, new p1.d(20), c0747k, vVar, new C0160e(i4, f4.e.booleanValue(), numValueOf, numValueOf2, numValueOf3));
        return Long.valueOf(j4);
    }

    public R0.f l(byte[] bArr) {
        try {
            this.e = new X0.c().c((String) this.f5454d);
            try {
                return new R0.f((d1.d0) ((d1.g0) C0747k.S(new R0.f(new ByteArrayInputStream(bArr), 1), (X0.b) this.e).f6831b).v(), 3);
            } catch (IOException | GeneralSecurityException e) {
                try {
                    return k(bArr);
                } catch (IOException unused) {
                    throw e;
                }
            }
        } catch (GeneralSecurityException | ProviderException e4) {
            try {
                R0.f fVarK = k(bArr);
                Log.w("a", "cannot use Android Keystore, it'll be disabled", e4);
                return fVarK;
            } catch (IOException unused2) {
                throw e4;
            }
        }
    }

    public X0.b m() throws KeyStoreException {
        X0.c cVar = new X0.c();
        try {
            boolean zA = X0.c.a((String) this.f5454d);
            try {
                return cVar.c((String) this.f5454d);
            } catch (GeneralSecurityException | ProviderException e) {
                if (!zA) {
                    throw new KeyStoreException(com.google.crypto.tink.shaded.protobuf.S.g("the master key ", (String) this.f5454d, " exists but is unusable"), e);
                }
                Log.w("a", "cannot use Android Keystore, it'll be disabled", e);
                return null;
            }
        } catch (GeneralSecurityException | ProviderException e4) {
            Log.w("a", "cannot use Android Keystore, it'll be disabled", e4);
            return null;
        }
    }

    public void o(Boolean bool) {
        C0161f c0161f = (C0161f) this.f5456g;
        C0747k c0747k = bool.booleanValue() ? (C0747k) this.f5455f : null;
        try {
            File fileCreateTempFile = File.createTempFile("REC", ".mp4", c0161f.f1945g.getCacheDir());
            c0161f.f1960w = fileCreateTempFile;
            try {
                c0161f.g(fileCreateTempFile.getAbsolutePath());
                E2.h hVar = c0161f.f1940a;
                D2.v vVar = c0161f.f1947i;
                c0161f.f1948j.getClass();
                hVar.f378a.put("AUTO_FOCUS", new V2.a(vVar, true));
                c0161f.n(c0161f.f1947i);
                if (c0747k != null) {
                    c0747k.Z(new B.k(c0161f, 16));
                }
                c0161f.f1943d = ((Integer) ((CameraCharacteristics) c0161f.f1947i.f260b).get(CameraCharacteristics.LENS_FACING)).intValue();
                c0161f.f1959u = true;
                try {
                    c0161f.o(true, c0747k != null);
                } catch (CameraAccessException e) {
                    c0161f.f1959u = false;
                    c0161f.f1960w = null;
                    throw new T2.v(null, "videoRecordingFailed", e.getMessage());
                }
            } catch (IOException e4) {
                c0161f.f1959u = false;
                c0161f.f1960w = null;
                throw new T2.v(null, "videoRecordingFailed", e4.getMessage());
            }
        } catch (IOException | SecurityException e5) {
            throw new T2.v(null, "cannotCreateFile", e5.getMessage());
        }
    }

    public String p() {
        C0161f c0161f = (C0161f) this.f5456g;
        if (!c0161f.f1959u) {
            return "";
        }
        E2.h hVar = c0161f.f1940a;
        D2.v vVar = c0161f.f1947i;
        c0161f.f1948j.getClass();
        hVar.f378a.put("AUTO_FOCUS", new V2.a(vVar, false));
        E2.h hVar2 = c0161f.f1940a;
        hVar2.f378a.put("FPS_RANGE", new C0247a(c0161f.f1947i));
        c0161f.f1959u = false;
        try {
            c0161f.b();
            c0161f.f1954p.abortCaptures();
            c0161f.f1958t.stop();
        } catch (CameraAccessException | IllegalStateException unused) {
        }
        c0161f.f1958t.reset();
        try {
            c0161f.p(null);
            String absolutePath = c0161f.f1960w.getAbsolutePath();
            c0161f.f1960w = null;
            return absolutePath;
        } catch (CameraAccessException | IllegalStateException | InterruptedException e) {
            throw new T2.v(null, "videoRecordingFailed", e.getMessage());
        }
    }
}
