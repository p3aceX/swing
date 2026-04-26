package a;

import D2.AbstractActivityC0029d;
import I3.l;
import J3.i;
import K.k;
import M3.e;
import M3.f;
import O.Z;
import Q3.L;
import T2.x;
import T2.y;
import X1.b;
import X1.c;
import X1.d;
import X1.g;
import X1.h;
import X1.j;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.os.SystemClock;
import android.view.View;
import android.widget.EdgeEffect;
import androidx.datastore.preferences.protobuf.C0196g;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0317w;
import com.google.crypto.tink.shaded.protobuf.AbstractC0320z;
import com.google.crypto.tink.shaded.protobuf.B;
import com.google.crypto.tink.shaded.protobuf.InterfaceC0319y;
import com.google.crypto.tink.shaded.protobuf.S;
import com.google.crypto.tink.shaded.protobuf.c0;
import com.google.crypto.tink.shaded.protobuf.f0;
import com.google.crypto.tink.shaded.protobuf.r0;
import e1.AbstractC0367g;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.lang.reflect.Array;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONObject;
import y3.InterfaceC0762c;

/* JADX INFO: renamed from: a.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0184a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static byte[] f2628a;

    public AbstractC0184a(Z z4) {
        i.e(z4, "operation");
    }

    public static boolean A(Object obj, Object obj2) {
        if ((obj instanceof byte[]) && (obj2 instanceof byte[])) {
            return Arrays.equals((byte[]) obj, (byte[]) obj2);
        }
        if ((obj instanceof int[]) && (obj2 instanceof int[])) {
            return Arrays.equals((int[]) obj, (int[]) obj2);
        }
        if ((obj instanceof long[]) && (obj2 instanceof long[])) {
            return Arrays.equals((long[]) obj, (long[]) obj2);
        }
        if ((obj instanceof double[]) && (obj2 instanceof double[])) {
            return Arrays.equals((double[]) obj, (double[]) obj2);
        }
        if ((obj instanceof Object[]) && (obj2 instanceof Object[])) {
            Object[] objArr = (Object[]) obj;
            Object[] objArr2 = (Object[]) obj2;
            if (objArr.length == objArr2.length) {
                Iterable fVar = new f(0, objArr.length - 1, 1);
                if (!(fVar instanceof Collection) || !((Collection) fVar).isEmpty()) {
                    Iterator it = fVar.iterator();
                    while (((e) it).f1100c) {
                        int iA = ((e) it).a();
                        if (!A(objArr[iA], objArr2[iA])) {
                        }
                    }
                }
                return true;
            }
            return false;
        }
        if ((obj instanceof List) && (obj2 instanceof List)) {
            List list = (List) obj;
            List list2 = (List) obj2;
            if (list.size() == list2.size()) {
                Collection collection = (Collection) obj;
                i.e(collection, "<this>");
                Iterable fVar2 = new f(0, collection.size() - 1, 1);
                if (!(fVar2 instanceof Collection) || !((Collection) fVar2).isEmpty()) {
                    Iterator it2 = fVar2.iterator();
                    while (((e) it2).f1100c) {
                        int iA2 = ((e) it2).a();
                        if (!A(list.get(iA2), list2.get(iA2))) {
                        }
                    }
                }
                return true;
            }
            return false;
        }
        if (!(obj instanceof Map) || !(obj2 instanceof Map)) {
            return i.a(obj, obj2);
        }
        Map map = (Map) obj;
        Map map2 = (Map) obj2;
        if (map.size() == map2.size()) {
            if (!map.isEmpty()) {
                for (Map.Entry entry : map.entrySet()) {
                    if (!map2.containsKey(entry.getKey()) || !A(entry.getValue(), map2.get(entry.getKey()))) {
                    }
                }
            }
            return true;
        }
        return false;
    }

    public static final void B(InterfaceC0762c interfaceC0762c, Throwable th) throws Throwable {
        if (th instanceof L) {
            th = ((L) th).f1593a;
        }
        interfaceC0762c.resumeWith(AbstractC0367g.h(th));
        throw th;
    }

    public static String D(C0196g c0196g) {
        StringBuilder sb = new StringBuilder(c0196g.size());
        for (int i4 = 0; i4 < c0196g.size(); i4++) {
            byte bF = c0196g.f(i4);
            if (bF == 34) {
                sb.append("\\\"");
            } else if (bF == 39) {
                sb.append("\\'");
            } else if (bF != 92) {
                switch (bF) {
                    case k.DOUBLE_FIELD_NUMBER /* 7 */:
                        sb.append("\\a");
                        break;
                    case k.BYTES_FIELD_NUMBER /* 8 */:
                        sb.append("\\b");
                        break;
                    case 9:
                        sb.append("\\t");
                        break;
                    case 10:
                        sb.append("\\n");
                        break;
                    case ModuleDescriptor.MODULE_VERSION /* 11 */:
                        sb.append("\\v");
                        break;
                    case 12:
                        sb.append("\\f");
                        break;
                    case 13:
                        sb.append("\\r");
                        break;
                    default:
                        if (bF < 32 || bF > 126) {
                            sb.append('\\');
                            sb.append((char) (((bF >>> 6) & 3) + 48));
                            sb.append((char) (((bF >>> 3) & 7) + 48));
                            sb.append((char) ((bF & 7) + 48));
                        } else {
                            sb.append((char) bF);
                        }
                        break;
                }
            } else {
                sb.append("\\\\");
            }
        }
        return sb.toString();
    }

    public static String E(AbstractC0303h abstractC0303h) {
        StringBuilder sb = new StringBuilder(abstractC0303h.size());
        for (int i4 = 0; i4 < abstractC0303h.size(); i4++) {
            byte bF = abstractC0303h.f(i4);
            if (bF == 34) {
                sb.append("\\\"");
            } else if (bF == 39) {
                sb.append("\\'");
            } else if (bF != 92) {
                switch (bF) {
                    case k.DOUBLE_FIELD_NUMBER /* 7 */:
                        sb.append("\\a");
                        break;
                    case k.BYTES_FIELD_NUMBER /* 8 */:
                        sb.append("\\b");
                        break;
                    case 9:
                        sb.append("\\t");
                        break;
                    case 10:
                        sb.append("\\n");
                        break;
                    case ModuleDescriptor.MODULE_VERSION /* 11 */:
                        sb.append("\\v");
                        break;
                    case 12:
                        sb.append("\\f");
                        break;
                    case 13:
                        sb.append("\\r");
                        break;
                    default:
                        if (bF < 32 || bF > 126) {
                            sb.append('\\');
                            sb.append((char) (((bF >>> 6) & 3) + 48));
                            sb.append((char) (((bF >>> 3) & 7) + 48));
                            sb.append((char) ((bF & 7) + 48));
                        } else {
                            sb.append((char) bF);
                        }
                        break;
                }
            } else {
                sb.append("\\\\");
            }
        }
        return sb.toString();
    }

    public static ArrayList F(ByteBuffer byteBuffer) {
        ArrayList arrayList = new ArrayList();
        int iRemaining = byteBuffer.remaining();
        byte[] bArr = new byte[iRemaining];
        byteBuffer.get(bArr, 0, iRemaining);
        byteBuffer.rewind();
        int i4 = -1;
        int i5 = -1;
        int i6 = -1;
        int i7 = 0;
        for (int i8 = 0; i8 < iRemaining; i8++) {
            if (i7 == 3 && bArr[i8] == 1) {
                if (i4 == -1) {
                    i4 = i8 - 3;
                } else if (i5 == -1) {
                    i5 = i8 - 3;
                } else {
                    i6 = i8 - 3;
                }
            }
            i7 = bArr[i8] == 0 ? i7 + 1 : 0;
        }
        if (i4 != -1 && i5 != -1 && i6 != -1) {
            byte[] bArr2 = new byte[i5];
            byte[] bArr3 = new byte[i6 - i5];
            byte[] bArr4 = new byte[iRemaining - i6];
            for (int i9 = 0; i9 < iRemaining; i9++) {
                if (i9 < i5) {
                    bArr2[i9] = bArr[i9];
                } else if (i9 < i6) {
                    bArr3[i9 - i5] = bArr[i9];
                } else {
                    bArr4[i9 - i6] = bArr[i9];
                }
            }
            arrayList.add(ByteBuffer.wrap(bArr2));
            arrayList.add(ByteBuffer.wrap(bArr3));
            arrayList.add(ByteBuffer.wrap(bArr4));
        }
        return arrayList;
    }

    public static b G(InputStream inputStream) throws IOException {
        Object next;
        b gVar;
        i.e(inputStream, "input");
        int i4 = inputStream.read();
        B3.b bVar = j.f2411u;
        bVar.getClass();
        J3.a aVar = new J3.a(bVar);
        while (true) {
            if (!aVar.hasNext()) {
                next = null;
                break;
            }
            next = aVar.next();
            if (((j) next).f2412a == i4) {
                break;
            }
        }
        j jVar = (j) next;
        if (jVar == null) {
            jVar = j.f2401d;
        }
        switch (jVar.ordinal()) {
            case 0:
                gVar = new g(0.0d);
                break;
            case 1:
                gVar = new X1.a(false);
                break;
            case 2:
                gVar = new X1.i();
                break;
            case 3:
                gVar = new h();
                break;
            case 4:
                gVar = new X1.f(0);
                break;
            case 5:
                gVar = new X1.f(1);
                break;
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                gVar = new d();
                break;
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
            default:
                throw new IOException(B1.a.m("Unimplemented AMF data type: ", jVar.name()));
            case k.BYTES_FIELD_NUMBER /* 8 */:
                gVar = new X1.e(new ArrayList());
                break;
            case 9:
                double dElapsedRealtime = SystemClock.elapsedRealtime();
                c cVar = new c();
                cVar.f2387a = dElapsedRealtime;
                gVar = cVar;
                break;
            case 10:
                gVar = new X1.e("");
                break;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                gVar = new X1.f(2);
                break;
            case 12:
                gVar = new X1.k("");
                break;
        }
        gVar.c(inputStream);
        return gVar;
    }

    public static ArrayList H(AbstractActivityC0029d abstractActivityC0029d) throws CameraAccessException {
        int i4;
        CameraManager cameraManager = (CameraManager) abstractActivityC0029d.getSystemService("camera");
        String[] cameraIdList = cameraManager.getCameraIdList();
        ArrayList arrayList = new ArrayList();
        for (String str : cameraIdList) {
            try {
                i4 = Integer.parseInt(str, 10);
            } catch (NumberFormatException unused) {
                i4 = -1;
            }
            if (i4 >= 0) {
                CameraCharacteristics cameraCharacteristics = cameraManager.getCameraCharacteristics(str);
                int iIntValue = ((Integer) cameraCharacteristics.get(CameraCharacteristics.SENSOR_ORIENTATION)).intValue();
                int iIntValue2 = ((Integer) cameraCharacteristics.get(CameraCharacteristics.LENS_FACING)).intValue();
                y yVar = y.FRONT;
                if (iIntValue2 != 0) {
                    if (iIntValue2 == 1) {
                        yVar = y.BACK;
                    } else if (iIntValue2 == 2) {
                        yVar = y.EXTERNAL;
                    }
                }
                Long lValueOf = Long.valueOf(iIntValue);
                x xVar = new x();
                if (str == null) {
                    throw new IllegalStateException("Nonnull field \"name\" is null.");
                }
                xVar.f2005a = str;
                xVar.f2006b = yVar;
                xVar.f2007c = lValueOf;
                arrayList.add(xVar);
            }
        }
        return arrayList;
    }

    public static float I(EdgeEffect edgeEffect) {
        if (Build.VERSION.SDK_INT >= 31) {
            return F.e.b(edgeEffect);
        }
        return 0.0f;
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    public static final Class J(N3.b bVar) {
        i.e(bVar, "<this>");
        Class clsA = ((J3.d) bVar).a();
        if (clsA.isPrimitive()) {
            String name = clsA.getName();
            switch (name.hashCode()) {
                case -1325958191:
                    if (name.equals("double")) {
                        return Double.class;
                    }
                    break;
                case 104431:
                    if (name.equals("int")) {
                        return Integer.class;
                    }
                    break;
                case 3039496:
                    if (name.equals("byte")) {
                        return Byte.class;
                    }
                    break;
                case 3052374:
                    if (name.equals("char")) {
                        return Character.class;
                    }
                    break;
                case 3327612:
                    if (name.equals("long")) {
                        return Long.class;
                    }
                    break;
                case 3625364:
                    if (name.equals("void")) {
                        return Void.class;
                    }
                    break;
                case 64711720:
                    if (name.equals("boolean")) {
                        return Boolean.class;
                    }
                    break;
                case 97526364:
                    if (name.equals("float")) {
                        return Float.class;
                    }
                    break;
                case 109413500:
                    if (name.equals("short")) {
                        return Short.class;
                    }
                    break;
            }
        }
        return clsA;
    }

    public static final int K(int i4, int i5, int i6) {
        if (i6 > 0) {
            if (i4 < i5) {
                int i7 = i5 % i6;
                if (i7 < 0) {
                    i7 += i6;
                }
                int i8 = i4 % i6;
                if (i8 < 0) {
                    i8 += i6;
                }
                int i9 = (i7 - i8) % i6;
                if (i9 < 0) {
                    i9 += i6;
                }
                return i5 - i9;
            }
        } else {
            if (i6 >= 0) {
                throw new IllegalArgumentException("Step is zero.");
            }
            if (i4 > i5) {
                int i10 = -i6;
                int i11 = i4 % i10;
                if (i11 < 0) {
                    i11 += i10;
                }
                int i12 = i5 % i10;
                if (i12 < 0) {
                    i12 += i10;
                }
                int i13 = (i11 - i12) % i10;
                if (i13 < 0) {
                    i13 += i10;
                }
                return i13 + i5;
            }
        }
        return i5;
    }

    public static String L(int i4) {
        switch (i4) {
            case -1:
                return "SUCCESS_CACHE";
            case 0:
                return "SUCCESS";
            case 1:
            case 9:
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
            case 12:
            default:
                return S.d(i4, "unknown status code: ");
            case 2:
                return "SERVICE_VERSION_UPDATE_REQUIRED";
            case 3:
                return "SERVICE_DISABLED";
            case 4:
                return "SIGN_IN_REQUIRED";
            case 5:
                return "INVALID_ACCOUNT";
            case k.STRING_SET_FIELD_NUMBER /* 6 */:
                return "RESOLUTION_REQUIRED";
            case k.DOUBLE_FIELD_NUMBER /* 7 */:
                return "NETWORK_ERROR";
            case k.BYTES_FIELD_NUMBER /* 8 */:
                return "INTERNAL_ERROR";
            case 10:
                return "DEVELOPER_ERROR";
            case 13:
                return "ERROR";
            case 14:
                return "INTERRUPTED";
            case 15:
                return "TIMEOUT";
            case 16:
                return "CANCELED";
            case 17:
                return "API_NOT_CONNECTED";
            case 18:
                return "DEAD_CLIENT";
            case 19:
                return "REMOTE_EXCEPTION";
            case 20:
                return "CONNECTION_SUSPENDED_DURING_CALL";
            case 21:
                return "RECONNECTION_TIMED_OUT_DURING_UPDATE";
            case 22:
                return "RECONNECTION_TIMED_OUT";
        }
    }

    public static long O(byte[] bArr, int i4) {
        return ((long) (((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16))) & 4294967295L;
    }

    public static int P(Object obj, c0 c0Var, byte[] bArr, int i4, int i5, U1.c cVar) throws B {
        int iW = i4 + 1;
        int i6 = bArr[i4];
        if (i6 < 0) {
            iW = w(i6, bArr, iW, cVar);
            i6 = cVar.f2097a;
        }
        int i7 = iW;
        if (i6 < 0 || i6 > i5 - i7) {
            throw B.g();
        }
        int i8 = i7 + i6;
        c0Var.g(obj, bArr, i7, i8, cVar);
        cVar.f2099c = obj;
        return i8;
    }

    public static float S(EdgeEffect edgeEffect, float f4, float f5) {
        if (Build.VERSION.SDK_INT >= 31) {
            return F.e.c(edgeEffect, f4, f5);
        }
        F.d.a(edgeEffect, f4, f5);
        return f4;
    }

    public static final byte[] U(InputStream inputStream) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream(Math.max(8192, inputStream.available()));
        m(inputStream, byteArrayOutputStream);
        byte[] byteArray = byteArrayOutputStream.toByteArray();
        i.d(byteArray, "toByteArray(...)");
        return byteArray;
    }

    public static boolean X(byte[] bArr, byte[] bArr2) {
        if (bArr2 != null && bArr.length >= bArr2.length) {
            for (int i4 = 0; i4 < bArr2.length; i4++) {
                if (bArr[i4] == bArr2[i4]) {
                }
            }
            return true;
        }
        return false;
    }

    public static void Y(byte[] bArr, long j4, int i4) {
        int i5 = 0;
        while (i5 < 4) {
            bArr[i4 + i5] = (byte) (255 & j4);
            i5++;
            j4 >>= 8;
        }
    }

    public static f Z(int i4, int i5) {
        if (i5 > Integer.MIN_VALUE) {
            return new f(i4, i5 - 1, 1);
        }
        f fVar = f.f1102d;
        return f.f1102d;
    }

    public static Object a0(Object obj) {
        if (obj == null) {
            return JSONObject.NULL;
        }
        if ((obj instanceof JSONArray) || (obj instanceof JSONObject) || obj.equals(JSONObject.NULL)) {
            return obj;
        }
        if (obj instanceof Collection) {
            JSONArray jSONArray = new JSONArray();
            Iterator it = ((Collection) obj).iterator();
            while (it.hasNext()) {
                jSONArray.put(a0(it.next()));
            }
            return jSONArray;
        }
        if (obj.getClass().isArray()) {
            JSONArray jSONArray2 = new JSONArray();
            int length = Array.getLength(obj);
            for (int i4 = 0; i4 < length; i4++) {
                jSONArray2.put(a0(Array.get(obj, i4)));
            }
            return jSONArray2;
        }
        if (obj instanceof Map) {
            JSONObject jSONObject = new JSONObject();
            for (Map.Entry entry : ((Map) obj).entrySet()) {
                jSONObject.put((String) entry.getKey(), a0(entry.getValue()));
            }
            return jSONObject;
        }
        if ((obj instanceof Boolean) || (obj instanceof Byte) || (obj instanceof Character) || (obj instanceof Double) || (obj instanceof Float) || (obj instanceof Integer) || (obj instanceof Long) || (obj instanceof Short) || (obj instanceof String)) {
            return obj;
        }
        if (obj.getClass().getPackage().getName().startsWith("java.")) {
            return obj.toString();
        }
        return null;
    }

    public static void b0(Parcel parcel, int i4, Bundle bundle, boolean z4) {
        if (bundle == null) {
            if (z4) {
                o0(parcel, i4, 0);
            }
        } else {
            int iM0 = m0(i4, parcel);
            parcel.writeBundle(bundle);
            n0(iM0, parcel);
        }
    }

    public static void c0(Parcel parcel, int i4, byte[] bArr, boolean z4) {
        if (bArr == null) {
            if (z4) {
                o0(parcel, i4, 0);
            }
        } else {
            int iM0 = m0(i4, parcel);
            parcel.writeByteArray(bArr);
            n0(iM0, parcel);
        }
    }

    public static void d0(Parcel parcel, int i4, Double d5) {
        if (d5 == null) {
            return;
        }
        o0(parcel, i4, 8);
        parcel.writeDouble(d5.doubleValue());
    }

    public static void e0(Parcel parcel, int i4, int[] iArr, boolean z4) {
        if (iArr == null) {
            if (z4) {
                o0(parcel, i4, 0);
            }
        } else {
            int iM0 = m0(i4, parcel);
            parcel.writeIntArray(iArr);
            n0(iM0, parcel);
        }
    }

    public static void f(StringBuilder sb, Object obj, l lVar) {
        if (lVar != null) {
            sb.append((CharSequence) lVar.invoke(obj));
            return;
        }
        if (obj == null ? true : obj instanceof CharSequence) {
            sb.append((CharSequence) obj);
        } else if (obj instanceof Character) {
            sb.append(((Character) obj).charValue());
        } else {
            sb.append((CharSequence) obj.toString());
        }
    }

    public static void f0(Parcel parcel, int i4, Integer num) {
        if (num == null) {
            return;
        }
        o0(parcel, i4, 4);
        parcel.writeInt(num.intValue());
    }

    public static void g0(Parcel parcel, int i4, Long l2) {
        if (l2 == null) {
            return;
        }
        o0(parcel, i4, 8);
        parcel.writeLong(l2.longValue());
    }

    public static Bitmap h(Bitmap bitmap, int i4) {
        if (bitmap != null) {
            switch (i4) {
                case 1:
                case 3:
                case k.STRING_SET_FIELD_NUMBER /* 6 */:
                case k.BYTES_FIELD_NUMBER /* 8 */:
                    break;
                case 2:
                case 4:
                case 5:
                case k.DOUBLE_FIELD_NUMBER /* 7 */:
                    int width = bitmap.getWidth();
                    int height = bitmap.getHeight();
                    Matrix matrix = new Matrix();
                    if (i4 == 2 || i4 == 7) {
                        matrix.setScale(-1.0f, 1.0f, width / 2.0f, height / 2.0f);
                    } else if (i4 == 4 || i4 == 5) {
                        matrix.setScale(1.0f, -1.0f, width / 2.0f, height / 2.0f);
                    }
                    Bitmap bitmapCreateBitmap = Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
                    if (bitmapCreateBitmap != bitmap) {
                        bitmap.recycle();
                    }
                    break;
                default:
                    S.j("Unknown EXIF orientation: ", i4, "ImageUtils");
                    break;
            }
            return bitmap;
        }
        return bitmap;
    }

    public static void h0(Parcel parcel, int i4, Parcelable parcelable, int i5, boolean z4) {
        if (parcelable == null) {
            if (z4) {
                o0(parcel, i4, 0);
            }
        } else {
            int iM0 = m0(i4, parcel);
            parcelable.writeToParcel(parcel, i5);
            n0(iM0, parcel);
        }
    }

    public static void i0(Parcel parcel, int i4, String str, boolean z4) {
        if (str == null) {
            if (z4) {
                o0(parcel, i4, 0);
            }
        } else {
            int iM0 = m0(i4, parcel);
            parcel.writeString(str);
            n0(iM0, parcel);
        }
    }

    public static float j(float f4, float f5, float f6) {
        if (f5 <= f6) {
            return f4 < f5 ? f5 : f4 > f6 ? f6 : f4;
        }
        throw new IllegalArgumentException("Cannot coerce value to an empty range: maximum " + f6 + " is less than minimum " + f5 + '.');
    }

    public static void j0(Parcel parcel, int i4, List list) {
        if (list == null) {
            return;
        }
        int iM0 = m0(i4, parcel);
        parcel.writeStringList(list);
        n0(iM0, parcel);
    }

    public static byte[] k(byte[] bArr, byte[] bArr2) {
        if (bArr.length != 32) {
            throw new IllegalArgumentException("The key length in bytes must be 32.");
        }
        long jO = O(bArr, 0) & 67108863;
        int i4 = 3;
        long jO2 = (O(bArr, 3) >> 2) & 67108611;
        long jO3 = (O(bArr, 6) >> 4) & 67092735;
        long jO4 = (O(bArr, 9) >> 6) & 66076671;
        long jO5 = (O(bArr, 12) >> 8) & 1048575;
        long j4 = jO2 * 5;
        long j5 = jO3 * 5;
        long j6 = jO4 * 5;
        long j7 = jO5 * 5;
        byte[] bArr3 = new byte[17];
        long j8 = 0;
        long j9 = 0;
        long j10 = 0;
        long j11 = 0;
        long j12 = 0;
        int i5 = 0;
        while (i5 < bArr2.length) {
            int iMin = Math.min(16, bArr2.length - i5);
            System.arraycopy(bArr2, i5, bArr3, 0, iMin);
            bArr3[iMin] = 1;
            if (iMin != 16) {
                Arrays.fill(bArr3, iMin + 1, 17, (byte) 0);
            }
            long jO6 = j12 + (O(bArr3, 0) & 67108863);
            long jO7 = j8 + ((O(bArr3, i4) >> 2) & 67108863);
            long jO8 = j9 + ((O(bArr3, 6) >> 4) & 67108863);
            long jO9 = j10 + ((O(bArr3, 9) >> 6) & 67108863);
            long j13 = jO2;
            long jO10 = j11 + (((O(bArr3, 12) >> 8) & 67108863) | ((long) (bArr3[16] << 24)));
            long j14 = (jO10 * j4) + (jO9 * j5) + (jO8 * j6) + (jO7 * j7) + (jO6 * jO);
            long j15 = (jO10 * j5) + (jO9 * j6) + (jO8 * j7) + (jO7 * jO) + (jO6 * j13);
            long j16 = (jO10 * j6) + (jO9 * j7) + (jO8 * jO) + (jO7 * j13) + (jO6 * jO3);
            long j17 = (jO10 * j7) + (jO9 * jO) + (jO8 * j13) + (jO7 * jO3) + (jO6 * jO4);
            long j18 = jO9 * j13;
            long j19 = jO10 * jO;
            long j20 = j15 + (j14 >> 26);
            long j21 = j16 + (j20 >> 26);
            long j22 = j17 + (j21 >> 26);
            long j23 = j19 + j18 + (jO8 * jO3) + (jO7 * jO4) + (jO6 * jO5) + (j22 >> 26);
            long j24 = j23 >> 26;
            j11 = j23 & 67108863;
            long j25 = (j24 * 5) + (j14 & 67108863);
            i5 += 16;
            j9 = j21 & 67108863;
            j10 = j22 & 67108863;
            j12 = j25 & 67108863;
            j8 = (j20 & 67108863) + (j25 >> 26);
            jO2 = j13;
            i4 = 3;
        }
        long j26 = j9 + (j8 >> 26);
        long j27 = j26 & 67108863;
        long j28 = j10 + (j26 >> 26);
        long j29 = j28 & 67108863;
        long j30 = j11 + (j28 >> 26);
        long j31 = j30 & 67108863;
        long j32 = ((j30 >> 26) * 5) + j12;
        long j33 = j32 >> 26;
        long j34 = j32 & 67108863;
        long j35 = (j8 & 67108863) + j33;
        long j36 = j34 + 5;
        long j37 = j36 & 67108863;
        long j38 = j35 + (j36 >> 26);
        long j39 = j27 + (j38 >> 26);
        long j40 = j29 + (j39 >> 26);
        long j41 = j40 & 67108863;
        long j42 = (j31 + (j40 >> 26)) - 67108864;
        long j43 = j42 >> 63;
        long j44 = j34 & j43;
        long j45 = j35 & j43;
        long j46 = j27 & j43;
        long j47 = j29 & j43;
        long j48 = j31 & j43;
        long j49 = ~j43;
        long j50 = j45 | (j38 & 67108863 & j49);
        long j51 = j46 | (j39 & 67108863 & j49);
        long j52 = j47 | (j41 & j49);
        long j53 = (j44 | (j37 & j49) | (j50 << 26)) & 4294967295L;
        long j54 = ((j50 >> 6) | (j51 << 20)) & 4294967295L;
        long j55 = ((j51 >> 12) | (j52 << 14)) & 4294967295L;
        long j56 = ((j52 >> 18) | ((j48 | (j42 & j49)) << 8)) & 4294967295L;
        long jO11 = O(bArr, 16) + j53;
        long j57 = jO11 & 4294967295L;
        long jO12 = O(bArr, 20) + j54 + (jO11 >> 32);
        long jO13 = O(bArr, 24) + j55 + (jO12 >> 32);
        long jO14 = (O(bArr, 28) + j56 + (jO13 >> 32)) & 4294967295L;
        byte[] bArr4 = new byte[16];
        Y(bArr4, j57, 0);
        Y(bArr4, jO12 & 4294967295L, 4);
        Y(bArr4, jO13 & 4294967295L, 8);
        Y(bArr4, jO14, 12);
        return bArr4;
    }

    public static void k0(Parcel parcel, int i4, Parcelable[] parcelableArr, int i5) {
        if (parcelableArr == null) {
            return;
        }
        int iM0 = m0(i4, parcel);
        parcel.writeInt(parcelableArr.length);
        for (Parcelable parcelable : parcelableArr) {
            if (parcelable == null) {
                parcel.writeInt(0);
            } else {
                int iDataPosition = parcel.dataPosition();
                parcel.writeInt(1);
                int iDataPosition2 = parcel.dataPosition();
                parcelable.writeToParcel(parcel, i5);
                int iDataPosition3 = parcel.dataPosition();
                parcel.setDataPosition(iDataPosition);
                parcel.writeInt(iDataPosition3 - iDataPosition2);
                parcel.setDataPosition(iDataPosition3);
            }
        }
        n0(iM0, parcel);
    }

    /* JADX WARN: Multi-variable type inference failed */
    public static long[] l(Serializable serializable) {
        if (!(serializable instanceof int[])) {
            if (serializable instanceof long[]) {
                return (long[]) serializable;
            }
            return null;
        }
        int[] iArr = (int[]) serializable;
        long[] jArr = new long[iArr.length];
        for (int i4 = 0; i4 < iArr.length; i4++) {
            jArr[i4] = iArr[i4];
        }
        return jArr;
    }

    public static void l0(Parcel parcel, int i4, List list, boolean z4) {
        if (list == null) {
            if (z4) {
                o0(parcel, i4, 0);
                return;
            }
            return;
        }
        int iM0 = m0(i4, parcel);
        int size = list.size();
        parcel.writeInt(size);
        for (int i5 = 0; i5 < size; i5++) {
            Parcelable parcelable = (Parcelable) list.get(i5);
            if (parcelable == null) {
                parcel.writeInt(0);
            } else {
                int iDataPosition = parcel.dataPosition();
                parcel.writeInt(1);
                int iDataPosition2 = parcel.dataPosition();
                parcelable.writeToParcel(parcel, 0);
                int iDataPosition3 = parcel.dataPosition();
                parcel.setDataPosition(iDataPosition);
                parcel.writeInt(iDataPosition3 - iDataPosition2);
                parcel.setDataPosition(iDataPosition3);
            }
        }
        n0(iM0, parcel);
    }

    public static void m(InputStream inputStream, ByteArrayOutputStream byteArrayOutputStream) throws IOException {
        byte[] bArr = new byte[8192];
        int i4 = inputStream.read(bArr);
        while (i4 >= 0) {
            byteArrayOutputStream.write(bArr, 0, i4);
            i4 = inputStream.read(bArr);
        }
    }

    public static int m0(int i4, Parcel parcel) {
        parcel.writeInt(i4 | (-65536));
        parcel.writeInt(0);
        return parcel.dataPosition();
    }

    public static byte[] n(byte[] bArr) {
        if (bArr.length != 16) {
            throw new IllegalArgumentException("value must be a block.");
        }
        byte[] bArr2 = new byte[16];
        for (int i4 = 0; i4 < 16; i4++) {
            byte b5 = (byte) ((bArr[i4] << 1) & 254);
            bArr2[i4] = b5;
            if (i4 < 15) {
                bArr2[i4] = (byte) (((byte) ((bArr[i4 + 1] >> 7) & 1)) | b5);
            }
        }
        bArr2[15] = (byte) (((byte) ((bArr[0] >> 7) & 135)) ^ bArr2[15]);
        return bArr2;
    }

    public static void n0(int i4, Parcel parcel) {
        int iDataPosition = parcel.dataPosition();
        parcel.setDataPosition(i4 - 4);
        parcel.writeInt(iDataPosition - i4);
        parcel.setDataPosition(iDataPosition);
    }

    public static int o(byte[] bArr, int i4, U1.c cVar) throws B {
        int iX = x(bArr, i4, cVar);
        int i5 = cVar.f2097a;
        if (i5 < 0) {
            throw B.e();
        }
        if (i5 > bArr.length - iX) {
            throw B.g();
        }
        if (i5 == 0) {
            cVar.f2099c = AbstractC0303h.f3791b;
            return iX;
        }
        cVar.f2099c = AbstractC0303h.h(bArr, iX, i5);
        return iX + i5;
    }

    public static void o0(Parcel parcel, int i4, int i5) {
        parcel.writeInt(i4 | (i5 << 16));
    }

    public static int p(byte[] bArr, int i4) {
        return ((bArr[i4 + 3] & 255) << 24) | (bArr[i4] & 255) | ((bArr[i4 + 1] & 255) << 8) | ((bArr[i4 + 2] & 255) << 16);
    }

    public static long q(byte[] bArr, int i4) {
        return ((((long) bArr[i4 + 7]) & 255) << 56) | (((long) bArr[i4]) & 255) | ((((long) bArr[i4 + 1]) & 255) << 8) | ((((long) bArr[i4 + 2]) & 255) << 16) | ((((long) bArr[i4 + 3]) & 255) << 24) | ((((long) bArr[i4 + 4]) & 255) << 32) | ((((long) bArr[i4 + 5]) & 255) << 40) | ((((long) bArr[i4 + 6]) & 255) << 48);
    }

    public static int r(c0 c0Var, int i4, byte[] bArr, int i5, int i6, InterfaceC0319y interfaceC0319y, U1.c cVar) throws B {
        Object objC = c0Var.c();
        c0 c0Var2 = c0Var;
        byte[] bArr2 = bArr;
        int i7 = i6;
        U1.c cVar2 = cVar;
        int iP = P(objC, c0Var2, bArr2, i5, i7, cVar2);
        c0Var2.d(objC);
        cVar2.f2099c = objC;
        interfaceC0319y.add(objC);
        while (iP < i7) {
            U1.c cVar3 = cVar2;
            int i8 = i7;
            int iX = x(bArr2, iP, cVar3);
            if (i4 != cVar3.f2097a) {
                break;
            }
            byte[] bArr3 = bArr2;
            c0 c0Var3 = c0Var2;
            Object objC2 = c0Var3.c();
            iP = P(objC2, c0Var3, bArr3, iX, i8, cVar3);
            c0Var2 = c0Var3;
            bArr2 = bArr3;
            i7 = i8;
            cVar2 = cVar3;
            c0Var2.d(objC2);
            cVar2.f2099c = objC2;
            interfaceC0319y.add(objC2);
        }
        return iP;
    }

    public static int s(byte[] bArr, int i4, U1.c cVar) throws B {
        int iX = x(bArr, i4, cVar);
        int i5 = cVar.f2097a;
        if (i5 < 0) {
            throw B.e();
        }
        if (i5 == 0) {
            cVar.f2099c = "";
            return iX;
        }
        cVar.f2099c = new String(bArr, iX, i5, AbstractC0320z.f3839a);
        return iX + i5;
    }

    public static int t(byte[] bArr, int i4, U1.c cVar) throws B {
        int iX = x(bArr, i4, cVar);
        int i5 = cVar.f2097a;
        if (i5 < 0) {
            throw B.e();
        }
        if (i5 == 0) {
            cVar.f2099c = "";
            return iX;
        }
        cVar.f2099c = r0.f3834a.v(bArr, iX, i5);
        return iX + i5;
    }

    public static int u(int i4, byte[] bArr, int i5, int i6, f0 f0Var, U1.c cVar) throws B {
        if ((i4 >>> 3) == 0) {
            throw B.a();
        }
        int i7 = i4 & 7;
        if (i7 == 0) {
            int iZ = z(bArr, i5, cVar);
            f0Var.d(i4, Long.valueOf(cVar.f2098b));
            return iZ;
        }
        if (i7 == 1) {
            f0Var.d(i4, Long.valueOf(q(bArr, i5)));
            return i5 + 8;
        }
        if (i7 == 2) {
            int iX = x(bArr, i5, cVar);
            int i8 = cVar.f2097a;
            if (i8 < 0) {
                throw B.e();
            }
            if (i8 > bArr.length - iX) {
                throw B.g();
            }
            if (i8 == 0) {
                f0Var.d(i4, AbstractC0303h.f3791b);
            } else {
                f0Var.d(i4, AbstractC0303h.h(bArr, iX, i8));
            }
            return iX + i8;
        }
        if (i7 != 3) {
            if (i7 != 5) {
                throw B.a();
            }
            f0Var.d(i4, Integer.valueOf(p(bArr, i5)));
            return i5 + 4;
        }
        f0 f0VarC = f0.c();
        int i9 = (i4 & (-8)) | 4;
        int i10 = 0;
        while (true) {
            if (i5 >= i6) {
                break;
            }
            int iX2 = x(bArr, i5, cVar);
            i10 = cVar.f2097a;
            if (i10 == i9) {
                i5 = iX2;
                break;
            }
            i5 = u(i10, bArr, iX2, i6, f0VarC, cVar);
        }
        if (i5 > i6 || i10 != i9) {
            throw B.f();
        }
        f0Var.d(i4, f0VarC);
        return i5;
    }

    public static int w(int i4, byte[] bArr, int i5, U1.c cVar) {
        int i6 = i4 & 127;
        int i7 = i5 + 1;
        byte b5 = bArr[i5];
        if (b5 >= 0) {
            cVar.f2097a = i6 | (b5 << 7);
            return i7;
        }
        int i8 = i6 | ((b5 & 127) << 7);
        int i9 = i5 + 2;
        byte b6 = bArr[i7];
        if (b6 >= 0) {
            cVar.f2097a = i8 | (b6 << 14);
            return i9;
        }
        int i10 = i8 | ((b6 & 127) << 14);
        int i11 = i5 + 3;
        byte b7 = bArr[i9];
        if (b7 >= 0) {
            cVar.f2097a = i10 | (b7 << 21);
            return i11;
        }
        int i12 = i10 | ((b7 & 127) << 21);
        int i13 = i5 + 4;
        byte b8 = bArr[i11];
        if (b8 >= 0) {
            cVar.f2097a = i12 | (b8 << 28);
            return i13;
        }
        int i14 = i12 | ((b8 & 127) << 28);
        while (true) {
            int i15 = i13 + 1;
            if (bArr[i13] >= 0) {
                cVar.f2097a = i14;
                return i15;
            }
            i13 = i15;
        }
    }

    public static int x(byte[] bArr, int i4, U1.c cVar) {
        int i5 = i4 + 1;
        byte b5 = bArr[i4];
        if (b5 < 0) {
            return w(b5, bArr, i5, cVar);
        }
        cVar.f2097a = b5;
        return i5;
    }

    public static int y(int i4, byte[] bArr, int i5, int i6, InterfaceC0319y interfaceC0319y, U1.c cVar) {
        AbstractC0317w abstractC0317w = (AbstractC0317w) interfaceC0319y;
        int iX = x(bArr, i5, cVar);
        abstractC0317w.g(cVar.f2097a);
        while (iX < i6) {
            int iX2 = x(bArr, iX, cVar);
            if (i4 != cVar.f2097a) {
                break;
            }
            iX = x(bArr, iX2, cVar);
            abstractC0317w.g(cVar.f2097a);
        }
        return iX;
    }

    public static int z(byte[] bArr, int i4, U1.c cVar) {
        int i5 = i4 + 1;
        long j4 = bArr[i4];
        if (j4 >= 0) {
            cVar.f2098b = j4;
            return i5;
        }
        int i6 = i4 + 2;
        byte b5 = bArr[i5];
        long j5 = (j4 & 127) | (((long) (b5 & 127)) << 7);
        int i7 = 7;
        while (b5 < 0) {
            int i8 = i6 + 1;
            byte b6 = bArr[i6];
            i7 += 7;
            j5 |= ((long) (b6 & 127)) << i7;
            b5 = b6;
            i6 = i8;
        }
        cVar.f2098b = j5;
        return i6;
    }

    public abstract int C(String str, byte[] bArr, int i4, int i5);

    public boolean M(byte[] bArr, int i4, int i5) {
        return T(bArr, i4, i5) == 0;
    }

    public boolean N() {
        throw null;
    }

    public abstract View Q(int i4);

    public abstract boolean R();

    public abstract int T(byte[] bArr, int i4, int i5);

    public abstract void W(boolean z4);

    public abstract String v(byte[] bArr, int i4, int i5);

    public void V(boolean z4) {
    }
}
