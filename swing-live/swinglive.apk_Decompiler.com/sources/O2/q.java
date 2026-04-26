package O2;

import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class q implements l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final q f1455a = new q();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final boolean f1456b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Charset f1457c;

    static {
        f1456b = ByteOrder.nativeOrder() == ByteOrder.LITTLE_ENDIAN;
        f1457c = Charset.forName("UTF8");
    }

    public static void c(ByteBuffer byteBuffer, int i4) {
        int iPosition = byteBuffer.position() % i4;
        if (iPosition != 0) {
            byteBuffer.position((byteBuffer.position() + i4) - iPosition);
        }
    }

    public static int d(ByteBuffer byteBuffer) {
        if (!byteBuffer.hasRemaining()) {
            throw new IllegalArgumentException("Message corrupted");
        }
        int i4 = byteBuffer.get() & 255;
        return i4 < 254 ? i4 : i4 == 254 ? byteBuffer.getChar() : byteBuffer.getInt();
    }

    public static void g(F3.a aVar, int i4) {
        int size = aVar.size() % i4;
        if (size != 0) {
            for (int i5 = 0; i5 < i4 - size; i5++) {
                aVar.write(0);
            }
        }
    }

    public static void h(F3.a aVar, int i4) {
        if (f1456b) {
            aVar.write(i4);
            aVar.write(i4 >>> 8);
            aVar.write(i4 >>> 16);
            aVar.write(i4 >>> 24);
            return;
        }
        aVar.write(i4 >>> 24);
        aVar.write(i4 >>> 16);
        aVar.write(i4 >>> 8);
        aVar.write(i4);
    }

    public static void i(F3.a aVar, long j4) {
        if (f1456b) {
            aVar.write((byte) j4);
            aVar.write((byte) (j4 >>> 8));
            aVar.write((byte) (j4 >>> 16));
            aVar.write((byte) (j4 >>> 24));
            aVar.write((byte) (j4 >>> 32));
            aVar.write((byte) (j4 >>> 40));
            aVar.write((byte) (j4 >>> 48));
            aVar.write((byte) (j4 >>> 56));
            return;
        }
        aVar.write((byte) (j4 >>> 56));
        aVar.write((byte) (j4 >>> 48));
        aVar.write((byte) (j4 >>> 40));
        aVar.write((byte) (j4 >>> 32));
        aVar.write((byte) (j4 >>> 24));
        aVar.write((byte) (j4 >>> 16));
        aVar.write((byte) (j4 >>> 8));
        aVar.write((byte) j4);
    }

    public static void j(F3.a aVar, int i4) {
        if (i4 < 254) {
            aVar.write(i4);
            return;
        }
        if (i4 > 65535) {
            aVar.write(255);
            h(aVar, i4);
            return;
        }
        aVar.write(254);
        if (f1456b) {
            aVar.write(i4);
            aVar.write(i4 >>> 8);
        } else {
            aVar.write(i4 >>> 8);
            aVar.write(i4);
        }
    }

    @Override // O2.l
    public final Object a(ByteBuffer byteBuffer) {
        if (byteBuffer == null) {
            return null;
        }
        byteBuffer.order(ByteOrder.nativeOrder());
        Object objE = e(byteBuffer);
        if (byteBuffer.hasRemaining()) {
            throw new IllegalArgumentException("Message corrupted");
        }
        return objE;
    }

    @Override // O2.l
    public final ByteBuffer b(Object obj) {
        if (obj == null) {
            return null;
        }
        F3.a aVar = new F3.a();
        k(aVar, obj);
        ByteBuffer byteBufferAllocateDirect = ByteBuffer.allocateDirect(aVar.size());
        byteBufferAllocateDirect.put(aVar.a(), 0, aVar.size());
        return byteBufferAllocateDirect;
    }

    public final Object e(ByteBuffer byteBuffer) {
        if (byteBuffer.hasRemaining()) {
            return f(byteBuffer.get(), byteBuffer);
        }
        throw new IllegalArgumentException("Message corrupted");
    }

    public Object f(byte b5, ByteBuffer byteBuffer) {
        Charset charset = f1457c;
        int i4 = 0;
        switch (b5) {
            case 0:
                return null;
            case 1:
                return Boolean.TRUE;
            case 2:
                return Boolean.FALSE;
            case 3:
                return Integer.valueOf(byteBuffer.getInt());
            case 4:
                return Long.valueOf(byteBuffer.getLong());
            case 5:
                byte[] bArr = new byte[d(byteBuffer)];
                byteBuffer.get(bArr);
                return new BigInteger(new String(bArr, charset), 16);
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                c(byteBuffer, 8);
                return Double.valueOf(byteBuffer.getDouble());
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                byte[] bArr2 = new byte[d(byteBuffer)];
                byteBuffer.get(bArr2);
                return new String(bArr2, charset);
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                byte[] bArr3 = new byte[d(byteBuffer)];
                byteBuffer.get(bArr3);
                return bArr3;
            case 9:
                int iD = d(byteBuffer);
                int[] iArr = new int[iD];
                c(byteBuffer, 4);
                byteBuffer.asIntBuffer().get(iArr);
                byteBuffer.position((iD * 4) + byteBuffer.position());
                return iArr;
            case 10:
                int iD2 = d(byteBuffer);
                long[] jArr = new long[iD2];
                c(byteBuffer, 8);
                byteBuffer.asLongBuffer().get(jArr);
                byteBuffer.position((iD2 * 8) + byteBuffer.position());
                return jArr;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                int iD3 = d(byteBuffer);
                double[] dArr = new double[iD3];
                c(byteBuffer, 8);
                byteBuffer.asDoubleBuffer().get(dArr);
                byteBuffer.position((iD3 * 8) + byteBuffer.position());
                return dArr;
            case 12:
                int iD4 = d(byteBuffer);
                ArrayList arrayList = new ArrayList(iD4);
                while (i4 < iD4) {
                    arrayList.add(e(byteBuffer));
                    i4++;
                }
                return arrayList;
            case 13:
                int iD5 = d(byteBuffer);
                HashMap map = new HashMap();
                while (i4 < iD5) {
                    map.put(e(byteBuffer), e(byteBuffer));
                    i4++;
                }
                return map;
            case 14:
                int iD6 = d(byteBuffer);
                float[] fArr = new float[iD6];
                c(byteBuffer, 4);
                byteBuffer.asFloatBuffer().get(fArr);
                byteBuffer.position((iD6 * 4) + byteBuffer.position());
                return fArr;
            default:
                throw new IllegalArgumentException("Message corrupted");
        }
    }

    public void k(F3.a aVar, Object obj) {
        int i4 = 0;
        if (obj == null || obj.equals(null)) {
            aVar.write(0);
            return;
        }
        if (obj instanceof Boolean) {
            aVar.write(((Boolean) obj).booleanValue() ? 1 : 2);
            return;
        }
        boolean z4 = obj instanceof Number;
        Charset charset = f1457c;
        if (z4) {
            if ((obj instanceof Integer) || (obj instanceof Short) || (obj instanceof Byte)) {
                aVar.write(3);
                h(aVar, ((Number) obj).intValue());
                return;
            }
            if (obj instanceof Long) {
                aVar.write(4);
                i(aVar, ((Long) obj).longValue());
                return;
            }
            if ((obj instanceof Float) || (obj instanceof Double)) {
                aVar.write(6);
                g(aVar, 8);
                i(aVar, Double.doubleToLongBits(((Number) obj).doubleValue()));
                return;
            } else {
                if (!(obj instanceof BigInteger)) {
                    throw new IllegalArgumentException("Unsupported Number type: " + obj.getClass());
                }
                aVar.write(5);
                byte[] bytes = ((BigInteger) obj).toString(16).getBytes(charset);
                j(aVar, bytes.length);
                aVar.write(bytes, 0, bytes.length);
                return;
            }
        }
        if (obj instanceof CharSequence) {
            aVar.write(7);
            byte[] bytes2 = obj.toString().getBytes(charset);
            j(aVar, bytes2.length);
            aVar.write(bytes2, 0, bytes2.length);
            return;
        }
        if (obj instanceof byte[]) {
            aVar.write(8);
            byte[] bArr = (byte[]) obj;
            j(aVar, bArr.length);
            aVar.write(bArr, 0, bArr.length);
            return;
        }
        if (obj instanceof int[]) {
            aVar.write(9);
            int[] iArr = (int[]) obj;
            j(aVar, iArr.length);
            g(aVar, 4);
            int length = iArr.length;
            while (i4 < length) {
                h(aVar, iArr[i4]);
                i4++;
            }
            return;
        }
        if (obj instanceof long[]) {
            aVar.write(10);
            long[] jArr = (long[]) obj;
            j(aVar, jArr.length);
            g(aVar, 8);
            int length2 = jArr.length;
            while (i4 < length2) {
                i(aVar, jArr[i4]);
                i4++;
            }
            return;
        }
        if (obj instanceof double[]) {
            aVar.write(11);
            double[] dArr = (double[]) obj;
            j(aVar, dArr.length);
            g(aVar, 8);
            int length3 = dArr.length;
            while (i4 < length3) {
                i(aVar, Double.doubleToLongBits(dArr[i4]));
                i4++;
            }
            return;
        }
        if (obj instanceof List) {
            aVar.write(12);
            List list = (List) obj;
            j(aVar, list.size());
            Iterator it = list.iterator();
            while (it.hasNext()) {
                k(aVar, it.next());
            }
            return;
        }
        if (obj instanceof Map) {
            aVar.write(13);
            Map map = (Map) obj;
            j(aVar, map.size());
            for (Map.Entry entry : map.entrySet()) {
                k(aVar, entry.getKey());
                k(aVar, entry.getValue());
            }
            return;
        }
        if (!(obj instanceof float[])) {
            throw new IllegalArgumentException("Unsupported value: '" + obj + "' of type '" + obj.getClass() + "'");
        }
        aVar.write(14);
        float[] fArr = (float[]) obj;
        j(aVar, fArr.length);
        g(aVar, 4);
        int length4 = fArr.length;
        while (i4 < length4) {
            h(aVar, Float.floatToIntBits(fArr[i4]));
            i4++;
        }
    }
}
