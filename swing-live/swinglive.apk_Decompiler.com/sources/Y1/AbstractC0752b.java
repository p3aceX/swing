package y1;

import J3.i;
import P3.m;
import Q3.C0152y;
import Q3.F;
import Q3.O;
import V3.o;
import android.hardware.camera2.CameraCharacteristics;
import android.media.MediaCodec;
import android.os.SystemClock;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import k.s0;
import x3.AbstractC0726f;
import z3.EnumC0789a;

/* JADX INFO: renamed from: y1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0752b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final int[] f6838a = {96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350, -1, -1, -1};

    public static final ByteBuffer a(ByteBuffer byteBuffer) {
        i.e(byteBuffer, "<this>");
        ByteBuffer byteBufferWrap = ByteBuffer.wrap(l(byteBuffer));
        i.d(byteBufferWrap, "wrap(...)");
        return byteBufferWrap;
    }

    public static ByteBuffer b(int i4, int i5, int i6, int i7) {
        int i8 = (i4 - 1) << 6;
        int[] iArr = f6838a;
        int i9 = 0;
        while (true) {
            if (i9 >= 16) {
                i9 = -1;
                break;
            }
            if (i6 == iArr[i9]) {
                break;
            }
            i9++;
        }
        if (i9 == -1) {
            i9 = 4;
        }
        ByteBuffer byteBufferWrap = ByteBuffer.wrap(new byte[]{-1, -15, (byte) (i8 | (i9 << 2) | (i7 >> 2)), (byte) (((i7 & 3) << 6) | (i5 >> 11)), (byte) ((i5 & 2047) >> 3), (byte) (((byte) ((i5 & 7) << 5)) + 31), -4});
        i.d(byteBufferWrap, "wrap(...)");
        return byteBufferWrap;
    }

    public static final long c() {
        return SystemClock.elapsedRealtimeNanos() / ((long) 1000);
    }

    public static final String d(String str) {
        i.e(str, "<this>");
        try {
            MessageDigest messageDigest = MessageDigest.getInstance("MD5");
            i.d(messageDigest, "getInstance(...)");
            byte[] bytes = str.getBytes(P3.a.f1492a);
            i.d(bytes, "getBytes(...)");
            byte[] bArrDigest = messageDigest.digest(bytes);
            i.d(bArrDigest, "digest(...)");
            return AbstractC0726f.i0(bArrDigest, "", new C0152y(4), 30);
        } catch (UnsupportedEncodingException | NoSuchAlgorithmException unused) {
            return "";
        }
    }

    public static final Object e(I3.a aVar, A3.c cVar) throws Throwable {
        X3.e eVar = O.f1596a;
        Object objB = F.B(o.f2244a, new C0756f(aVar, null), cVar);
        return objB == EnumC0789a.f6999a ? objB : w3.i.f6729a;
    }

    public static s0 f(String str, String[] strArr) throws URISyntaxException {
        URI uri = new URI(str);
        if (uri.getScheme() != null) {
            String scheme = uri.getScheme();
            i.d(scheme, "getScheme(...)");
            if (!AbstractC0726f.c0(strArr, m.J0(scheme).toString())) {
                throw new URISyntaxException(str, B1.a.m("Invalid protocol: ", uri.getScheme()));
            }
        }
        if (uri.getUserInfo() != null) {
            String userInfo = uri.getUserInfo();
            i.d(userInfo, "getUserInfo(...)");
            if (!m.q0(userInfo, ":", false)) {
                throw new URISyntaxException(str, "Invalid auth. Auth must contain ':'");
            }
        }
        if (uri.getHost() == null) {
            throw new URISyntaxException(str, B1.a.m("Invalid host: ", uri.getHost()));
        }
        if (uri.getPath() == null) {
            throw new URISyntaxException(str, B1.a.m("Invalid path: ", uri.getHost()));
        }
        s0 s0Var = new s0();
        s0Var.f5451a = str;
        s0Var.f5452b = "";
        s0Var.f5453c = "";
        s0Var.e = "";
        String string = uri.toString();
        i.d(string, "toString(...)");
        String scheme2 = uri.getScheme();
        i.d(scheme2, "getScheme(...)");
        s0Var.f5452b = scheme2;
        String host = uri.getHost();
        i.d(host, "getHost(...)");
        s0Var.f5453c = host;
        s0Var.f5454d = uri.getPort() < 0 ? null : Integer.valueOf(uri.getPort());
        String path = uri.getPath();
        i.d(path, "getPath(...)");
        s0Var.e = m.z0(path, "/");
        if (uri.getQuery() != null) {
            String query = uri.getQuery();
            i.d(query, "getQuery(...)");
            int iU0 = m.u0(0, 6, string, query, false);
            String strSubstring = string.substring(iU0 >= 0 ? iU0 : 0);
            i.d(strSubstring, "substring(...)");
            s0Var.f5455f = strSubstring;
        }
        s0Var.f5456g = uri.getUserInfo();
        return s0Var;
    }

    public static final int g(InputStream inputStream) {
        i.e(inputStream, "<this>");
        byte[] bArr = new byte[2];
        inputStream.read(bArr);
        return ((bArr[0] & 255) << 8) | (bArr[1] & 255);
    }

    public static final int h(InputStream inputStream) {
        i.e(inputStream, "<this>");
        byte[] bArr = new byte[4];
        inputStream.read(bArr);
        return o(bArr);
    }

    public static final void i(InputStream inputStream, byte[] bArr) throws IOException {
        i.e(inputStream, "<this>");
        int i4 = 0;
        while (i4 < bArr.length) {
            int i5 = inputStream.read(bArr, i4, bArr.length - i4);
            if (i5 != -1) {
                i4 += i5;
            }
        }
    }

    public static final ByteBuffer j(ByteBuffer byteBuffer, B1.b bVar) {
        try {
            byteBuffer.position(bVar.f108a);
            byteBuffer.limit(bVar.f109b);
        } catch (Exception unused) {
        }
        ByteBuffer byteBufferSlice = byteBuffer.slice();
        i.d(byteBufferSlice, "slice(...)");
        return byteBufferSlice;
    }

    public static final Object k(CameraCharacteristics cameraCharacteristics, CameraCharacteristics.Key key) {
        try {
            return cameraCharacteristics.get(key);
        } catch (IllegalArgumentException unused) {
            return null;
        }
    }

    public static final byte[] l(ByteBuffer byteBuffer) {
        i.e(byteBuffer, "<this>");
        if (byteBuffer.hasArray() && !byteBuffer.isDirect()) {
            byte[] bArrArray = byteBuffer.array();
            i.b(bArrArray);
            return bArrArray;
        }
        byteBuffer.rewind();
        byte[] bArr = new byte[byteBuffer.remaining()];
        byteBuffer.get(bArr);
        return bArr;
    }

    public static final B1.b m(MediaCodec.BufferInfo bufferInfo) {
        i.e(bufferInfo, "<this>");
        return new B1.b(bufferInfo.offset, bufferInfo.size, bufferInfo.presentationTimeUs, bufferInfo.flags == 1);
    }

    public static final int n(byte[] bArr) {
        i.e(bArr, "<this>");
        return (bArr[2] & 255) | ((bArr[0] & 255) << 16) | ((bArr[1] & 255) << 8);
    }

    public static final int o(byte[] bArr) {
        i.e(bArr, "<this>");
        return (bArr[3] & 255) | ((bArr[0] & 255) << 24) | ((bArr[1] & 255) << 16) | ((bArr[2] & 255) << 8);
    }

    public static final byte[] p(int i4) {
        return new byte[]{(byte) (i4 >>> 24), (byte) (i4 >>> 16), (byte) (i4 >>> 8), (byte) i4};
    }

    public static final String q(Throwable th) {
        i.e(th, "<this>");
        String message = th.getMessage();
        if (message == null) {
            message = "";
        }
        return message.length() == 0 ? th.getClass().getSimpleName() : message;
    }

    public static final void r(OutputStream outputStream, int i4) throws IOException {
        i.e(outputStream, "<this>");
        outputStream.write(new byte[]{(byte) (i4 >>> 8), (byte) i4});
    }

    public static final void s(OutputStream outputStream, int i4) throws IOException {
        i.e(outputStream, "<this>");
        outputStream.write(p(i4));
    }
}
