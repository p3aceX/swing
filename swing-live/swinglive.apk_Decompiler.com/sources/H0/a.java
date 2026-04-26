package H0;

import A.C;
import F.m;
import F.n;
import F.o;
import H2.d;
import I3.p;
import J3.i;
import K.j;
import K.k;
import M3.f;
import O.AbstractActivityC0114z;
import Q3.C0149v;
import Q3.E0;
import Q3.F;
import Q3.L;
import T2.v;
import V3.r;
import X.B;
import X.t;
import X.u;
import android.R;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.TypedArray;
import android.graphics.Paint;
import android.hardware.camera2.params.MeteringRectangle;
import android.media.MediaCodecInfo;
import android.media.MediaCodecList;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.opengl.GLES20;
import android.os.Build;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.os.Trace;
import android.text.TextDirectionHeuristic;
import android.text.TextDirectionHeuristics;
import android.text.TextPaint;
import android.text.method.PasswordTransformationMethod;
import android.util.Log;
import android.util.Size;
import android.util.SparseArray;
import android.view.ActionMode;
import android.view.KeyEvent;
import android.view.View;
import android.widget.TextView;
import b0.AbstractC0242a;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.crypto.tink.shaded.protobuf.S;
import io.flutter.plugins.GeneratedPluginRegistrant;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import k.C0504v;
import u1.C0690c;
import y.C0735b;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public abstract class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static Context f508a = null;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static Boolean f509b = null;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static boolean f510c = false;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static Method f511d;
    public static long e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static Method f512f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static Method f513g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public static Method f514h;

    public static ArrayList A(String str) {
        ArrayList arrayList = new ArrayList();
        ArrayList<MediaCodecInfo> arrayList2 = new ArrayList();
        arrayList2.addAll(Arrays.asList(new MediaCodecList(1).getCodecInfos()));
        ArrayList<MediaCodecInfo> arrayList3 = new ArrayList();
        ArrayList arrayList4 = new ArrayList();
        ArrayList arrayList5 = new ArrayList();
        for (MediaCodecInfo mediaCodecInfo : arrayList2) {
            if (!mediaCodecInfo.getName().equalsIgnoreCase("aacencoder")) {
                String name = mediaCodecInfo.getName();
                int iB = j.b(name.equalsIgnoreCase("c2.sec.aac.encoder") ? 3 : name.equalsIgnoreCase("omx.google.aac.encoder") ? 2 : 1);
                if (iB == 1) {
                    arrayList4.add(mediaCodecInfo);
                } else if (iB != 2) {
                    arrayList3.add(mediaCodecInfo);
                } else {
                    arrayList5.add(mediaCodecInfo);
                }
            }
        }
        arrayList3.addAll(arrayList4);
        arrayList3.addAll(arrayList5);
        for (MediaCodecInfo mediaCodecInfo2 : arrayList3) {
            if (mediaCodecInfo2.isEncoder()) {
                for (String str2 : mediaCodecInfo2.getSupportedTypes()) {
                    if (str2.equalsIgnoreCase(str)) {
                        arrayList.add(mediaCodecInfo2);
                    }
                }
            }
        }
        return arrayList;
    }

    public static ArrayList B(String str) {
        ArrayList arrayList = new ArrayList();
        ArrayList<MediaCodecInfo> arrayListC = C(str, false);
        ArrayList<MediaCodecInfo> arrayListD = D(str, false);
        ArrayList arrayList2 = new ArrayList();
        ArrayList arrayList3 = new ArrayList();
        ArrayList arrayList4 = new ArrayList();
        ArrayList arrayList5 = new ArrayList();
        for (MediaCodecInfo mediaCodecInfo : arrayListC) {
            if (I(mediaCodecInfo, str)) {
                arrayList2.add(mediaCodecInfo);
            } else {
                arrayList3.add(mediaCodecInfo);
            }
        }
        for (MediaCodecInfo mediaCodecInfo2 : arrayListD) {
            if (I(mediaCodecInfo2, str)) {
                arrayList4.add(mediaCodecInfo2);
            } else {
                arrayList5.add(mediaCodecInfo2);
            }
        }
        arrayList.addAll(arrayList2);
        arrayList.addAll(arrayList4);
        arrayList.addAll(arrayList3);
        arrayList.addAll(arrayList5);
        return arrayList;
    }

    public static ArrayList C(String str, boolean z4) {
        ArrayList<MediaCodecInfo> arrayListA = A(str);
        ArrayList arrayList = new ArrayList();
        ArrayList arrayList2 = new ArrayList();
        for (MediaCodecInfo mediaCodecInfo : arrayListA) {
            if (Build.VERSION.SDK_INT >= 29 ? mediaCodecInfo.isHardwareAccelerated() : !N(mediaCodecInfo)) {
                arrayList.add(mediaCodecInfo);
                if (z4 && I(mediaCodecInfo, str)) {
                    arrayList2.add(mediaCodecInfo);
                }
            }
        }
        arrayList.removeAll(arrayList2);
        arrayList.addAll(0, arrayList2);
        return arrayList;
    }

    public static ArrayList D(String str, boolean z4) {
        ArrayList<MediaCodecInfo> arrayListA = A(str);
        ArrayList arrayList = new ArrayList();
        ArrayList arrayList2 = new ArrayList();
        for (MediaCodecInfo mediaCodecInfo : arrayListA) {
            if (N(mediaCodecInfo)) {
                arrayList.add(mediaCodecInfo);
                if (z4 && I(mediaCodecInfo, str)) {
                    arrayList2.add(mediaCodecInfo);
                }
            }
        }
        arrayList.removeAll(arrayList2);
        arrayList.addAll(0, arrayList2);
        return arrayList;
    }

    public static String E(Context context, int i4) {
        try {
            InputStream inputStreamOpenRawResource = context.getResources().openRawResource(i4);
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            for (int i5 = inputStreamOpenRawResource.read(); i5 != -1; i5 = inputStreamOpenRawResource.read()) {
                byteArrayOutputStream.write(i5);
            }
            String string = byteArrayOutputStream.toString();
            inputStreamOpenRawResource.close();
            return string;
        } catch (IOException e4) {
            throw new RuntimeException("Read shader from disk failed: " + e4.getMessage());
        }
    }

    public static C0735b G(C0504v c0504v) {
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 28) {
            return new C0735b(o.c(c0504v));
        }
        TextPaint textPaint = new TextPaint(c0504v.getPaint());
        TextDirectionHeuristic textDirectionHeuristic = TextDirectionHeuristics.FIRSTSTRONG_LTR;
        int iA = m.a(c0504v);
        int iD = m.d(c0504v);
        if (c0504v.getTransformationMethod() instanceof PasswordTransformationMethod) {
            textDirectionHeuristic = TextDirectionHeuristics.LTR;
        } else if (i4 < 28 || (c0504v.getInputType() & 15) != 3) {
            boolean z4 = c0504v.getLayoutDirection() == 1;
            switch (c0504v.getTextDirection()) {
                case 2:
                    textDirectionHeuristic = TextDirectionHeuristics.ANYRTL_LTR;
                    break;
                case 3:
                    textDirectionHeuristic = TextDirectionHeuristics.LTR;
                    break;
                case 4:
                    textDirectionHeuristic = TextDirectionHeuristics.RTL;
                    break;
                case 5:
                    textDirectionHeuristic = TextDirectionHeuristics.LOCALE;
                    break;
                case k.STRING_SET_FIELD_NUMBER /* 6 */:
                    break;
                case k.DOUBLE_FIELD_NUMBER /* 7 */:
                    textDirectionHeuristic = TextDirectionHeuristics.FIRSTSTRONG_RTL;
                    break;
                default:
                    if (z4) {
                        textDirectionHeuristic = TextDirectionHeuristics.FIRSTSTRONG_RTL;
                    }
                    break;
            }
        } else {
            byte directionality = Character.getDirectionality(o.b(n.a(c0504v.getTextLocale()))[0].codePointAt(0));
            textDirectionHeuristic = (directionality == 1 || directionality == 2) ? TextDirectionHeuristics.RTL : TextDirectionHeuristics.LTR;
        }
        return new C0735b(textPaint, textDirectionHeuristic, iA, iD);
    }

    public static void H(String str, Exception exc) {
        if (exc instanceof InvocationTargetException) {
            Throwable cause = exc.getCause();
            if (!(cause instanceof RuntimeException)) {
                throw new RuntimeException(cause);
            }
            throw ((RuntimeException) cause);
        }
        Log.v("Trace", "Unable to call " + str + " via reflection", exc);
    }

    public static boolean I(MediaCodecInfo mediaCodecInfo, String str) {
        return mediaCodecInfo.getCapabilitiesForType(str).getEncoderCapabilities().isBitrateModeSupported(2);
    }

    public static boolean J() {
        if (Build.VERSION.SDK_INT >= 29) {
            return AbstractC0242a.c();
        }
        try {
            if (f512f == null) {
                e = Trace.class.getField("TRACE_TAG_APP").getLong(null);
                f512f = Trace.class.getMethod("isTagEnabled", Long.TYPE);
            }
            return ((Boolean) f512f.invoke(null, Long.valueOf(e))).booleanValue();
        } catch (Exception e4) {
            H("isTagEnabled", e4);
            return false;
        }
    }

    public static boolean K(Context context) {
        Bundle bundle;
        Context applicationContext = context.getApplicationContext();
        try {
            bundle = applicationContext.getPackageManager().getApplicationInfo(applicationContext.getPackageName(), 128).metaData;
        } catch (PackageManager.NameNotFoundException unused) {
            Log.e("ContentSizingFlag", "Could not get metadata");
            bundle = null;
        }
        if (bundle != null) {
            return bundle.getBoolean("io.flutter.embedding.android.EnableContentSizing", false);
        }
        return false;
    }

    public static boolean L(byte b5) {
        return b5 > -65;
    }

    public static boolean M(byte b5) {
        return b5 > -65;
    }

    public static boolean N(MediaCodecInfo mediaCodecInfo) {
        if (Build.VERSION.SDK_INT >= 29) {
            return !mediaCodecInfo.isHardwareAccelerated();
        }
        String lowerCase = mediaCodecInfo.getName().toLowerCase();
        if (lowerCase.startsWith("arc.")) {
            return false;
        }
        return lowerCase.startsWith("omx.google.") || lowerCase.startsWith("omx.ffmpeg.") || (lowerCase.startsWith("omx.sec.") && lowerCase.contains(".sw.")) || lowerCase.equals("omx.qcom.video.decoder.hevcswvdec") || lowerCase.startsWith("c2.android.") || lowerCase.startsWith("c2.google.") || !(lowerCase.startsWith("omx.") || lowerCase.startsWith("c2."));
    }

    public static final boolean O(char c5) {
        return Character.isWhitespace(c5) || Character.isSpaceChar(c5);
    }

    public static int P(int i4, String str) {
        int iGlCreateShader = GLES20.glCreateShader(i4);
        GLES20.glShaderSource(iGlCreateShader, str);
        GLES20.glCompileShader(iGlCreateShader);
        int[] iArr = new int[1];
        GLES20.glGetShaderiv(iGlCreateShader, 35713, iArr, 0);
        if (iArr[0] != 0) {
            return iGlCreateShader;
        }
        StringBuilder sbI = S.i("Could not compile shader ", i4, ": ");
        sbI.append(GLES20.glGetShaderInfoLog(iGlCreateShader));
        String string = sbI.toString();
        GLES20.glDeleteShader(iGlCreateShader);
        throw new RuntimeException(string);
    }

    public static void R(d dVar, MediaExtractor mediaExtractor) {
        try {
            int trackCount = mediaExtractor.getTrackCount();
            for (int i4 = 0; i4 < trackCount; i4++) {
                MediaFormat trackFormat = mediaExtractor.getTrackFormat(i4);
                String string = trackFormat.getString("mime");
                if (string != null && string.startsWith("image/")) {
                    int integer = trackFormat.containsKey("rotation-degrees") ? trackFormat.getInteger("rotation-degrees") : 0;
                    int i5 = dVar.f534g;
                    int i6 = dVar.f533f;
                    if (integer != 90 && integer != 270) {
                        i6 = i5;
                        i5 = i6;
                    }
                    dVar.f530b = i5;
                    dVar.f529a = i6;
                    dVar.f531c = integer;
                    return;
                }
            }
        } catch (Exception e4) {
            Log.e("MediaMetadataReader", "Failed to decode HEIF image using MediaExtractor", e4);
        }
    }

    public static boolean S(int i4, Parcel parcel) {
        n0(parcel, i4, 4);
        return parcel.readInt() != 0;
    }

    public static Double T(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        if (iY == 0) {
            return null;
        }
        m0(parcel, iY, 8);
        return Double.valueOf(parcel.readDouble());
    }

    public static int U(int i4, Parcel parcel) {
        n0(parcel, i4, 4);
        return parcel.readInt();
    }

    public static Integer V(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        if (iY == 0) {
            return null;
        }
        m0(parcel, iY, 4);
        return Integer.valueOf(parcel.readInt());
    }

    public static long W(int i4, Parcel parcel) {
        n0(parcel, i4, 8);
        return parcel.readLong();
    }

    public static Long X(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        if (iY == 0) {
            return null;
        }
        m0(parcel, iY, 8);
        return Long.valueOf(parcel.readLong());
    }

    public static int Y(int i4, Parcel parcel) {
        return (i4 & (-65536)) != -65536 ? (char) (i4 >> 16) : parcel.readInt();
    }

    public static void Z(E2.c cVar) {
        try {
            GeneratedPluginRegistrant.class.getDeclaredMethod("registerWith", E2.c.class).invoke(null, cVar);
        } catch (Exception e4) {
            Log.e("GeneratedPluginsRegister", "Tried to automatically register plugins with FlutterEngine (" + cVar + ") but could not find or invoke the GeneratedPluginRegistrant.");
            Log.e("GeneratedPluginsRegister", "Received exception while registering", e4);
        }
    }

    public static final ArrayList a(ArrayList arrayList) {
        ArrayList arrayList2 = new ArrayList();
        Iterator it = arrayList.iterator();
        while (it.hasNext()) {
            Q0.k kVar = (Q0.k) it.next();
            Bundle bundle = new Bundle();
            bundle.putInt("event_type", kVar.f1534a);
            bundle.putLong("event_timestamp", kVar.f1535b);
            arrayList2.add(bundle);
        }
        return arrayList2;
    }

    /* JADX WARN: Removed duplicated region for block: B:27:0x006b  */
    /* JADX WARN: Removed duplicated region for block: B:37:0x0091  */
    /* JADX WARN: Removed duplicated region for block: B:39:0x0094  */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:33:0x0082 -> B:25:0x0065). Please report as a decompilation issue!!! */
    /* JADX WARN: Unsupported multi-entry loop pattern (BACK_EDGE: B:34:0x0085 -> B:25:0x0065). Please report as a decompilation issue!!! */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static final java.lang.Object b(java.util.List r6, I.C0051l r7, A3.c r8) throws java.lang.Throwable {
        /*
            boolean r0 = r8 instanceof I.C0045f
            if (r0 == 0) goto L13
            r0 = r8
            I.f r0 = (I.C0045f) r0
            int r1 = r0.f654d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f654d = r1
            goto L18
        L13:
            I.f r0 = new I.f
            r0.<init>(r8)
        L18:
            java.lang.Object r8 = r0.f653c
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f654d
            r3 = 2
            r4 = 1
            if (r2 == 0) goto L42
            if (r2 == r4) goto L3a
            if (r2 != r3) goto L32
            java.util.Iterator r6 = r0.f652b
            java.io.Serializable r7 = r0.f651a
            J3.r r7 = (J3.r) r7
            e1.AbstractC0367g.M(r8)     // Catch: java.lang.Throwable -> L30
            goto L65
        L30:
            r8 = move-exception
            goto L7e
        L32:
            java.lang.IllegalStateException r6 = new java.lang.IllegalStateException
            java.lang.String r7 = "call to 'resume' before 'invoke' with coroutine"
            r6.<init>(r7)
            throw r6
        L3a:
            java.io.Serializable r6 = r0.f651a
            java.util.List r6 = (java.util.List) r6
            e1.AbstractC0367g.M(r8)
            goto L5c
        L42:
            e1.AbstractC0367g.M(r8)
            java.util.ArrayList r8 = new java.util.ArrayList
            r8.<init>()
            I.h r2 = new I.h
            r5 = 0
            r2.<init>(r6, r8, r5)
            r0.f651a = r8
            r0.f654d = r4
            java.lang.Object r6 = r7.a(r2, r0)
            if (r6 != r1) goto L5b
            goto L93
        L5b:
            r6 = r8
        L5c:
            J3.r r7 = new J3.r
            r7.<init>()
            java.util.Iterator r6 = r6.iterator()
        L65:
            boolean r8 = r6.hasNext()
            if (r8 == 0) goto L8b
            java.lang.Object r8 = r6.next()
            I3.l r8 = (I3.l) r8
            r0.f651a = r7     // Catch: java.lang.Throwable -> L30
            r0.f652b = r6     // Catch: java.lang.Throwable -> L30
            r0.f654d = r3     // Catch: java.lang.Throwable -> L30
            java.lang.Object r8 = r8.invoke(r0)     // Catch: java.lang.Throwable -> L30
            if (r8 != r1) goto L65
            goto L93
        L7e:
            java.lang.Object r2 = r7.f832a
            if (r2 != 0) goto L85
            r7.f832a = r8
            goto L65
        L85:
            java.lang.Throwable r2 = (java.lang.Throwable) r2
            e1.k.b(r2, r8)
            goto L65
        L8b:
            java.lang.Object r6 = r7.f832a
            java.lang.Throwable r6 = (java.lang.Throwable) r6
            if (r6 != 0) goto L94
            w3.i r1 = w3.i.f6729a
        L93:
            return r1
        L94:
            throw r6
        */
        throw new UnsupportedOperationException("Method not decompiled: H0.a.b(java.util.List, I.l, A3.c):java.lang.Object");
    }

    public static void b0(TextView textView, int i4) {
        if (i4 < 0) {
            throw new IllegalArgumentException();
        }
        if (Build.VERSION.SDK_INT >= 28) {
            o.d(textView, i4);
            return;
        }
        Paint.FontMetricsInt fontMetricsInt = textView.getPaint().getFontMetricsInt();
        int i5 = textView.getIncludeFontPadding() ? fontMetricsInt.top : fontMetricsInt.ascent;
        if (i4 > Math.abs(i5)) {
            textView.setPadding(textView.getPaddingLeft(), i4 + i5, textView.getPaddingRight(), textView.getPaddingBottom());
        }
    }

    public static void c(int i4) {
        if (2 > i4 || i4 >= 37) {
            StringBuilder sbI = S.i("radix ", i4, " was not in valid range ");
            sbI.append(new f(2, 36, 1));
            throw new IllegalArgumentException(sbI.toString());
        }
    }

    public static void c0(TextView textView, int i4) {
        if (i4 < 0) {
            throw new IllegalArgumentException();
        }
        Paint.FontMetricsInt fontMetricsInt = textView.getPaint().getFontMetricsInt();
        int i5 = textView.getIncludeFontPadding() ? fontMetricsInt.bottom : fontMetricsInt.descent;
        if (i4 > Math.abs(i5)) {
            textView.setPadding(textView.getPaddingLeft(), textView.getPaddingTop(), textView.getPaddingRight(), i4 - i5);
        }
    }

    public static final void d(Closeable closeable, Throwable th) throws IllegalAccessException, IOException, InvocationTargetException {
        if (closeable != null) {
            if (th == null) {
                closeable.close();
                return;
            }
            try {
                closeable.close();
            } catch (Throwable th2) {
                e1.k.b(th, th2);
            }
        }
    }

    public static void d0(Status status, Object obj, TaskCompletionSource taskCompletionSource) {
        if (status.b()) {
            taskCompletionSource.setResult(obj);
        } else {
            taskCompletionSource.setException(new com.google.android.gms.common.api.j(status));
        }
    }

    public static int e(B b5, Q.b bVar, View view, View view2, t tVar, boolean z4) {
        if (tVar.p() == 0 || b5.a() == 0 || view == null || view2 == null) {
            return 0;
        }
        if (z4) {
            return Math.min(bVar.g(), bVar.c(view2) - bVar.d(view));
        }
        ((u) view.getLayoutParams()).getClass();
        throw null;
    }

    public static void e0(int i4, Parcel parcel) {
        parcel.setDataPosition(parcel.dataPosition() + Y(i4, parcel));
    }

    public static int f(B b5, Q.b bVar, View view, View view2, t tVar, boolean z4) {
        if (tVar.p() == 0 || b5.a() == 0 || view == null || view2 == null) {
            return 0;
        }
        if (!z4) {
            return b5.a();
        }
        bVar.c(view2);
        bVar.d(view);
        ((u) view.getLayoutParams()).getClass();
        throw null;
    }

    public static final Object f0(r rVar, boolean z4, r rVar2, p pVar) throws Throwable {
        Object c0149v;
        Object objP;
        try {
            if (pVar == null) {
                c0149v = e1.k.J(pVar, rVar2, rVar);
            } else {
                J3.u.a(2, pVar);
                c0149v = pVar.invoke(rVar2, rVar);
            }
        } catch (L e4) {
            Throwable th = e4.f1593a;
            rVar.O(new C0149v(th, false));
            throw th;
        } catch (Throwable th2) {
            c0149v = new C0149v(th2, false);
        }
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        if (c0149v == enumC0789a || (objP = rVar.P(c0149v)) == F.e) {
            return enumC0789a;
        }
        rVar.f0();
        if (!(objP instanceof C0149v)) {
            return F.z(objP);
        }
        if (!z4) {
            Throwable th3 = ((C0149v) objP).f1666a;
            if ((th3 instanceof E0) && ((E0) th3).f1575a == rVar) {
                if (c0149v instanceof C0149v) {
                    throw ((C0149v) c0149v).f1666a;
                }
                return c0149v;
            }
        }
        throw ((C0149v) objP).f1666a;
    }

    public static MeteringRectangle g(Size size, double d5, double d6, int i4) {
        double d7;
        double d8;
        int iB = j.b(i4);
        if (iB == 0) {
            d7 = 1.0d - d5;
            d8 = d6;
        } else if (iB == 1) {
            d8 = 1.0d - d6;
            d7 = d5;
        } else if (iB != 3) {
            d8 = d5;
            d7 = d6;
        } else {
            d7 = 1.0d - d6;
            d8 = 1.0d - d5;
        }
        int iRound = (int) Math.round(d8 * ((double) (size.getWidth() - 1)));
        int iRound2 = (int) Math.round(d7 * ((double) (size.getHeight() - 1)));
        int iRound3 = (int) Math.round(((double) size.getWidth()) / 10.0d);
        int iRound4 = (int) Math.round(((double) size.getHeight()) / 10.0d);
        int i5 = iRound - (iRound3 / 2);
        int i6 = iRound2 - (iRound4 / 2);
        if (i5 < 0) {
            i5 = 0;
        }
        if (i6 < 0) {
            i6 = 0;
        }
        int width = (size.getWidth() - 1) - iRound3;
        int height = (size.getHeight() - 1) - iRound4;
        if (i5 > width) {
            i5 = width;
        }
        if (i6 > height) {
            i6 = height;
        }
        return new MeteringRectangle(i5, i6, iRound3, iRound4, 1);
    }

    public static int g0(Context context, int i4) {
        TypedArray typedArrayObtainStyledAttributes = context.obtainStyledAttributes(R.style.Animation.Activity, new int[]{i4});
        int resourceId = typedArrayObtainStyledAttributes.getResourceId(0, -1);
        typedArrayObtainStyledAttributes.recycle();
        return resourceId;
    }

    public static BigDecimal h(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        byte[] bArrCreateByteArray = parcel.createByteArray();
        int i5 = parcel.readInt();
        parcel.setDataPosition(iDataPosition + iY);
        return new BigDecimal(new BigInteger(bArrCreateByteArray), i5);
    }

    public static String h0(String str) {
        return str.length() <= 127 ? str : str.substring(0, 127);
    }

    public static Bundle i(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        Bundle bundle = parcel.readBundle();
        parcel.setDataPosition(iDataPosition + iY);
        return bundle;
    }

    public static int i0(Parcel parcel) {
        int i4 = parcel.readInt();
        int iY = Y(i4, parcel);
        char c5 = (char) i4;
        int iDataPosition = parcel.dataPosition();
        if (c5 != 20293) {
            throw new A0.b("Expected object header. Got 0x".concat(String.valueOf(Integer.toHexString(i4))), parcel);
        }
        int i5 = iY + iDataPosition;
        if (i5 < iDataPosition || i5 > parcel.dataSize()) {
            throw new A0.b(B1.a.k("Size read is invalid start=", iDataPosition, i5, " end="), parcel);
        }
        return i5;
    }

    public static byte[] j(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        byte[] bArrCreateByteArray = parcel.createByteArray();
        parcel.setDataPosition(iDataPosition + iY);
        return bArrCreateByteArray;
    }

    public static ActionMode.Callback j0(ActionMode.Callback callback, TextView textView) {
        int i4 = Build.VERSION.SDK_INT;
        return (i4 < 26 || i4 > 27 || (callback instanceof F.p) || callback == null) ? callback : new F.p(callback, textView);
    }

    public static v k(String str) {
        return new v("", "channel-error", S.g("Unable to establish connection on channel: ", str, "."));
    }

    public static ArrayList k0(Throwable th) {
        ArrayList arrayList = new ArrayList(3);
        if (th instanceof v) {
            v vVar = (v) th;
            arrayList.add(vVar.f2002a);
            arrayList.add(vVar.getMessage());
            arrayList.add(vVar.f2003b);
            return arrayList;
        }
        arrayList.add(th.toString());
        arrayList.add(th.getClass().getSimpleName());
        arrayList.add("Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
        return arrayList;
    }

    public static int[] m(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        int[] iArrCreateIntArray = parcel.createIntArray();
        parcel.setDataPosition(iDataPosition + iY);
        return iArrCreateIntArray;
    }

    public static void m0(Parcel parcel, int i4, int i5) {
        if (i4 == i5) {
            return;
        }
        String hexString = Integer.toHexString(i4);
        StringBuilder sb = new StringBuilder("Expected size ");
        sb.append(i5);
        sb.append(" got ");
        sb.append(i4);
        sb.append(" (0x");
        throw new A0.b(S.h(sb, hexString, ")"), parcel);
    }

    public static void n0(Parcel parcel, int i4, int i5) {
        int iY = Y(i4, parcel);
        if (iY == i5) {
            return;
        }
        String hexString = Integer.toHexString(iY);
        StringBuilder sb = new StringBuilder("Expected size ");
        sb.append(i5);
        sb.append(" got ");
        sb.append(iY);
        sb.append(" (0x");
        throw new A0.b(S.h(sb, hexString, ")"), parcel);
    }

    public static Parcelable o(Parcel parcel, int i4, Parcelable.Creator creator) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        Parcelable parcelable = (Parcelable) creator.createFromParcel(parcel);
        parcel.setDataPosition(iDataPosition + iY);
        return parcelable;
    }

    public static int p(String str, String str2) {
        int iP = P(35633, str);
        int iP2 = P(35632, str2);
        int iGlCreateProgram = GLES20.glCreateProgram();
        if (iGlCreateProgram == 0) {
            throw new RuntimeException("Could not create program");
        }
        GLES20.glAttachShader(iGlCreateProgram, iP);
        GLES20.glAttachShader(iGlCreateProgram, iP2);
        GLES20.glLinkProgram(iGlCreateProgram);
        int[] iArr = new int[1];
        GLES20.glGetProgramiv(iGlCreateProgram, 35714, iArr, 0);
        if (iArr[0] == 1) {
            return iGlCreateProgram;
        }
        String str3 = "Could not link program: " + GLES20.glGetProgramInfoLog(iGlCreateProgram);
        GLES20.glDeleteProgram(iGlCreateProgram);
        throw new RuntimeException(str3);
    }

    public static String q(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        String string = parcel.readString();
        parcel.setDataPosition(iDataPosition + iY);
        return string;
    }

    public static ArrayList r(int i4, Parcel parcel) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        ArrayList<String> arrayListCreateStringArrayList = parcel.createStringArrayList();
        parcel.setDataPosition(iDataPosition + iY);
        return arrayListCreateStringArrayList;
    }

    public static void s(int[] iArr, int i4, boolean z4) {
        GLES20.glGenTextures(i4, iArr, 0);
        int i5 = z4 ? 36197 : 3553;
        for (int i6 = 0; i6 < i4; i6++) {
            GLES20.glActiveTexture(33984 + i6);
            GLES20.glBindTexture(i5, iArr[i6]);
            float f4 = 9729;
            GLES20.glTexParameterf(i5, 10241, f4);
            GLES20.glTexParameterf(i5, 10240, f4);
            GLES20.glTexParameteri(i5, 10242, 33071);
            GLES20.glTexParameteri(i5, 10243, 33071);
        }
    }

    public static Object[] t(Parcel parcel, int i4, Parcelable.Creator creator) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        Object[] objArrCreateTypedArray = parcel.createTypedArray(creator);
        parcel.setDataPosition(iDataPosition + iY);
        return objArrCreateTypedArray;
    }

    public static ArrayList u(Parcel parcel, int i4, Parcelable.Creator creator) {
        int iY = Y(i4, parcel);
        int iDataPosition = parcel.dataPosition();
        if (iY == 0) {
            return null;
        }
        ArrayList arrayListCreateTypedArrayList = parcel.createTypedArrayList(creator);
        parcel.setDataPosition(iDataPosition + iY);
        return arrayListCreateTypedArrayList;
    }

    public static A0.c v(byte[] bArr, Parcelable.Creator creator) {
        com.google.android.gms.common.internal.F.g(creator);
        Parcel parcelObtain = Parcel.obtain();
        parcelObtain.unmarshall(bArr, 0, bArr.length);
        parcelObtain.setDataPosition(0);
        A0.c cVar = (A0.c) creator.createFromParcel(parcelObtain);
        parcelObtain.recycle();
        return cVar;
    }

    public static void w(int... iArr) {
        for (int i4 : iArr) {
            if (i4 >= 0 && i4 < 34921) {
                GLES20.glDisableVertexAttribArray(i4);
            }
        }
        GLES20.glBindTexture(36197, 0);
        GLES20.glBindTexture(3553, 0);
        GLES20.glUseProgram(0);
    }

    public static boolean x(View view, KeyEvent keyEvent) {
        ArrayList arrayList;
        int size;
        int iIndexOfKey;
        Field field = C.f4a;
        if (Build.VERSION.SDK_INT >= 28) {
            return false;
        }
        ArrayList arrayList2 = A.B.f0d;
        A.B b5 = (A.B) view.getTag(com.swing.live.R.id.tag_unhandled_key_event_manager);
        WeakReference weakReference = null;
        if (b5 == null) {
            b5 = new A.B();
            b5.f1a = null;
            b5.f2b = null;
            b5.f3c = null;
            view.setTag(com.swing.live.R.id.tag_unhandled_key_event_manager, b5);
        }
        WeakReference weakReference2 = b5.f3c;
        if (weakReference2 != null && weakReference2.get() == keyEvent) {
            return false;
        }
        b5.f3c = new WeakReference(keyEvent);
        if (b5.f2b == null) {
            b5.f2b = new SparseArray();
        }
        SparseArray sparseArray = b5.f2b;
        if (keyEvent.getAction() == 1 && (iIndexOfKey = sparseArray.indexOfKey(keyEvent.getKeyCode())) >= 0) {
            weakReference = (WeakReference) sparseArray.valueAt(iIndexOfKey);
            sparseArray.removeAt(iIndexOfKey);
        }
        if (weakReference == null) {
            weakReference = (WeakReference) sparseArray.get(keyEvent.getKeyCode());
        }
        if (weakReference == null) {
            return false;
        }
        View view2 = (View) weakReference.get();
        if (view2 == null || !view2.isAttachedToWindow() || (arrayList = (ArrayList) view2.getTag(com.swing.live.R.id.tag_unhandled_key_listeners)) == null || (size = arrayList.size() - 1) < 0) {
            return true;
        }
        arrayList.get(size).getClass();
        throw new ClassCastException();
    }

    public static void y(int i4, Parcel parcel) {
        if (parcel.dataPosition() != i4) {
            throw new A0.b(S.d(i4, "Overread allowed size end="), parcel);
        }
    }

    public static final B3.b z(Enum[] enumArr) {
        i.e(enumArr, "entries");
        return new B3.b(enumArr);
    }

    public C0690c F(AbstractActivityC0114z abstractActivityC0114z, Intent intent) {
        return null;
    }

    public abstract Object Q(int i4, Intent intent);

    public abstract void a0(boolean z4);

    public abstract Object l(B1.d dVar, p pVar, InterfaceC0762c interfaceC0762c);

    public abstract void l0(byte[] bArr, int i4, int i5);

    public abstract Intent n(AbstractActivityC0114z abstractActivityC0114z, Intent intent);
}
