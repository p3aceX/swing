package m2;

import Q3.F;
import Q3.O;
import a.AbstractC0184a;
import android.os.SystemClock;
import android.util.Log;
import e1.AbstractC0367g;
import e2.C0371C;
import e2.C0377I;
import g2.n;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.net.URLConnection;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import javax.net.ssl.HttpsURLConnection;
import x3.s;
import y1.AbstractC0752b;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class i extends AbstractC0367g {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final String f5811c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f5812d;
    public final boolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final Object f5813f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final int f5814g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public String f5815h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public boolean f5816i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final AtomicLong f5817j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final ByteArrayOutputStream f5818k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public ByteArrayInputStream f5819l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final Object f5820m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f5821n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final int f5822o;

    public i(String str, int i4, boolean z4) {
        J3.i.e(str, "host");
        this.f5811c = str;
        this.f5812d = i4;
        this.e = z4;
        this.f5813f = s.d0(new w3.c("Content-Type", "application/x-fcs"), new w3.c("User-Agent", "Shockwave Flash"));
        this.f5814g = 5000;
        this.f5815h = "";
        this.f5817j = new AtomicLong(0L);
        this.f5818k = new ByteArrayOutputStream();
        this.f5819l = new ByteArrayInputStream(new byte[0]);
        this.f5820m = new Object();
        this.f5822o = 10;
    }

    @Override // e1.AbstractC0367g
    public final Object B(A3.c cVar) {
        X3.e eVar = O.f1596a;
        return F.B(X3.d.f2437c, new f(this, null), cVar);
    }

    @Override // e1.AbstractC0367g
    public final Object F(InterfaceC0762c interfaceC0762c) throws IOException {
        ByteArrayInputStream byteArrayInputStreamD0 = d0(1);
        J3.i.e(byteArrayInputStreamD0, "<this>");
        byte[] bArr = new byte[3];
        byteArrayInputStreamD0.read(bArr);
        return new Integer(AbstractC0752b.n(bArr));
    }

    @Override // e1.AbstractC0367g
    public final Object G(InterfaceC0762c interfaceC0762c) {
        return new Integer(AbstractC0752b.h(d0(1)));
    }

    @Override // e1.AbstractC0367g
    public final Object H(InterfaceC0762c interfaceC0762c) {
        ByteArrayInputStream byteArrayInputStreamD0 = d0(1);
        J3.i.e(byteArrayInputStreamD0, "<this>");
        return new Integer(Integer.reverseBytes(AbstractC0752b.h(byteArrayInputStreamD0)));
    }

    @Override // e1.AbstractC0367g
    public final Object I(byte[] bArr, A3.c cVar) throws IOException {
        AbstractC0752b.i(d0(bArr.length), bArr);
        return w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object Q(int i4, A3.c cVar) throws Throwable {
        X3.e eVar = O.f1596a;
        Object objB = F.B(X3.d.f2437c, new g(this, i4, null), cVar);
        return objB == EnumC0789a.f6999a ? objB : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object R(byte[] bArr, int i4, int i5, n nVar) {
        this.f5818k.write(bArr, i4, i5);
        return w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object S(byte[] bArr, A3.c cVar) throws Throwable {
        X3.e eVar = O.f1596a;
        Object objB = F.B(X3.d.f2437c, new h(this, bArr, null), cVar);
        return objB == EnumC0789a.f6999a ? objB : w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object T(int i4, g2.i iVar) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = this.f5818k;
        J3.i.e(byteArrayOutputStream, "<this>");
        byteArrayOutputStream.write(new byte[]{(byte) (i4 >>> 16), (byte) (i4 >>> 8), (byte) i4});
        return w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object U(int i4, g2.i iVar) throws IOException {
        AbstractC0752b.s(this.f5818k, i4);
        return w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object V(int i4, g2.i iVar) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = this.f5818k;
        J3.i.e(byteArrayOutputStream, "<this>");
        byteArrayOutputStream.write(AbstractC0752b.p(Integer.reverseBytes(i4)));
        return w3.i.f6729a;
    }

    @Override // e1.AbstractC0367g
    public final Object c(C0371C c0371c) {
        Log.i("TcpTunneledSocket", "closing tunneled socket...");
        this.f5816i = false;
        synchronized (this.f5820m) {
            new Thread(new F1.a(this, 17)).start();
        }
        return w3.i.f6729a;
    }

    /* JADX WARN: Type inference failed for: r5v5, types: [java.lang.Object, java.util.Map] */
    public final HttpURLConnection c0(String str, boolean z4) throws IOException {
        HttpURLConnection httpURLConnection;
        URL url = new URL((z4 ? "https" : "http") + "://" + this.f5811c + ":" + this.f5812d + "/" + str);
        if (z4) {
            URLConnection uRLConnectionOpenConnection = url.openConnection();
            J3.i.c(uRLConnectionOpenConnection, "null cannot be cast to non-null type javax.net.ssl.HttpsURLConnection");
            httpURLConnection = (HttpsURLConnection) uRLConnectionOpenConnection;
        } else {
            URLConnection uRLConnectionOpenConnection2 = url.openConnection();
            J3.i.c(uRLConnectionOpenConnection2, "null cannot be cast to non-null type java.net.HttpURLConnection");
            httpURLConnection = (HttpURLConnection) uRLConnectionOpenConnection2;
        }
        Log.i("TcpTunneledSocket", "open: " + url);
        httpURLConnection.setRequestMethod("POST");
        for (Map.Entry entry : this.f5813f.entrySet()) {
            httpURLConnection.addRequestProperty((String) entry.getKey(), (String) entry.getValue());
        }
        httpURLConnection.setDoOutput(true);
        int i4 = this.f5814g;
        httpURLConnection.setConnectTimeout(i4);
        httpURLConnection.setReadTimeout(i4);
        return httpURLConnection;
    }

    public final ByteArrayInputStream d0(int i4) {
        if (this.f5819l.available() >= i4) {
            return this.f5819l;
        }
        synchronized (this.f5820m) {
            long jElapsedRealtime = SystemClock.elapsedRealtime();
            while (this.f5819l.available() <= 1 && this.f5816i) {
                long jAddAndGet = this.f5817j.addAndGet(1L);
                byte[] bArrE0 = e0("idle/" + this.f5815h + "/" + jAddAndGet, this.e);
                this.f5819l = new ByteArrayInputStream(bArrE0, 1, bArrE0.length);
                if (SystemClock.elapsedRealtime() - jElapsedRealtime >= this.f5814g) {
                    throw new SocketTimeoutException("couldn't receive a valid packet");
                }
            }
        }
        return this.f5819l;
    }

    public final byte[] e0(String str, boolean z4) throws IOException {
        HttpURLConnection httpURLConnectionC0 = c0(str, z4);
        try {
            httpURLConnectionC0.connect();
            InputStream inputStream = httpURLConnectionC0.getInputStream();
            J3.i.d(inputStream, "getInputStream(...)");
            byte[] bArrU = AbstractC0184a.U(inputStream);
            if (httpURLConnectionC0.getResponseCode() == 200) {
                return bArrU;
            }
            throw new IOException("receive packet failed: " + httpURLConnectionC0.getResponseMessage() + ", broken pipe");
        } finally {
            httpURLConnectionC0.disconnect();
        }
    }

    @Override // e1.AbstractC0367g
    public final Object f(C0377I c0377i) {
        synchronized (this.f5820m) {
            try {
                f0("fcs/ident2", this.e, new byte[]{0});
            } catch (IOException unused) {
            }
            try {
                String strP0 = P3.f.p0(new String(e0("open/1", this.e), P3.a.f1492a));
                this.f5815h = strP0;
                f0("idle/" + strP0 + "/" + this.f5817j.get(), this.e, new byte[]{0});
                this.f5816i = true;
                A3.g.a(Log.i("TcpTunneledSocket", "Connection success"));
            } catch (IOException e) {
                Log.e("TcpTunneledSocket", "Connection failed: " + e.getMessage());
                this.f5816i = false;
            }
        }
        return w3.i.f6729a;
    }

    public final void f0(String str, boolean z4, byte[] bArr) throws IOException {
        HttpURLConnection httpURLConnectionC0 = c0(str, z4);
        try {
            httpURLConnectionC0.connect();
            httpURLConnectionC0.getOutputStream().write(bArr);
            InputStream inputStream = httpURLConnectionC0.getInputStream();
            J3.i.d(inputStream, "getInputStream(...)");
            byte[] bArrU = AbstractC0184a.U(inputStream);
            if (bArrU.length > 1) {
                this.f5819l = new ByteArrayInputStream(bArrU, 1, bArrU.length);
            }
            if (httpURLConnectionC0.getResponseCode() == 200) {
                httpURLConnectionC0.disconnect();
                return;
            }
            throw new IOException("send packet failed: " + httpURLConnectionC0.getResponseMessage() + ", broken pipe");
        } catch (Throwable th) {
            httpURLConnectionC0.disconnect();
            throw th;
        }
    }

    @Override // e1.AbstractC0367g
    public final Object s(boolean z4, A3.c cVar) {
        synchronized (this.f5820m) {
            if (z4) {
                int i4 = this.f5821n;
                if (i4 < this.f5822o) {
                    this.f5821n = i4 + 1;
                    return w3.i.f6729a;
                }
            }
            if (!this.f5816i) {
                return w3.i.f6729a;
            }
            long jAddAndGet = this.f5817j.addAndGet(1L);
            byte[] byteArray = this.f5818k.toByteArray();
            this.f5818k.reset();
            String str = "send/" + this.f5815h + "/" + jAddAndGet;
            boolean z5 = this.e;
            J3.i.b(byteArray);
            f0(str, z5, byteArray);
            this.f5821n = 0;
            return w3.i.f6729a;
        }
    }

    @Override // e1.AbstractC0367g
    public final boolean x() {
        return this.f5816i;
    }
}
