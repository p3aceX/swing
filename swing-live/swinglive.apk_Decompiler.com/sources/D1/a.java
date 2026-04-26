package D1;

import J3.i;
import e1.AbstractC0367g;
import g2.n;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Serializable;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import javax.net.ssl.SSLContext;
import y1.AbstractC0752b;
import y3.InterfaceC0762c;

/* JADX INFO: loaded from: classes.dex */
public final class a extends C1.b {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Socket f140b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public BufferedInputStream f141c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public BufferedOutputStream f142d;
    public final String e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final int f143f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final boolean f144g;

    public a(String str, int i4, boolean z4) {
        i.e(str, "host");
        this.f140b = new Socket();
        this.f141c = new BufferedInputStream(new ByteArrayInputStream(new byte[0]), 8192);
        this.f142d = new BufferedOutputStream(new ByteArrayOutputStream(), 8192);
        new BufferedReader(new InputStreamReader(this.f141c), 8192);
        this.e = str;
        this.f143f = i4;
        this.f144g = z4;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:7:0x0013  */
    /* JADX WARN: Type inference failed for: r4v3, types: [byte[], java.io.Serializable] */
    /* JADX WARN: Type inference failed for: r5v1, types: [byte[], java.io.Serializable] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static java.io.Serializable k(D1.a r4, int r5, A3.c r6) throws java.io.IOException {
        /*
            boolean r0 = r6 instanceof D1.b
            if (r0 == 0) goto L13
            r0 = r6
            D1.b r0 = (D1.b) r0
            int r1 = r0.f148d
            r2 = -2147483648(0xffffffff80000000, float:-0.0)
            r3 = r1 & r2
            if (r3 == 0) goto L13
            int r1 = r1 - r2
            r0.f148d = r1
            goto L18
        L13:
            D1.b r0 = new D1.b
            r0.<init>(r4, r6)
        L18:
            java.lang.Object r6 = r0.f146b
            z3.a r1 = z3.EnumC0789a.f6999a
            int r2 = r0.f148d
            r3 = 1
            if (r2 == 0) goto L31
            if (r2 != r3) goto L29
            byte[] r4 = r0.f145a
            e1.AbstractC0367g.M(r6)
            return r4
        L29:
            java.lang.IllegalStateException r4 = new java.lang.IllegalStateException
            java.lang.String r5 = "call to 'resume' before 'invoke' with coroutine"
            r4.<init>(r5)
            throw r4
        L31:
            e1.AbstractC0367g.M(r6)
            byte[] r5 = new byte[r5]
            r0.f145a = r5
            r0.f148d = r3
            r4.g(r5, r0)
            w3.i r4 = w3.i.f6729a
            if (r4 != r1) goto L42
            return r1
        L42:
            return r5
        */
        throw new UnsupportedOperationException("Method not decompiled: D1.a.k(D1.a, int, A3.c):java.io.Serializable");
    }

    @Override // C1.b
    public final Object a(InterfaceC0762c interfaceC0762c) {
        if (this.f140b.isConnected()) {
            try {
                this.f140b.shutdownOutput();
            } catch (Throwable th) {
                AbstractC0367g.h(th);
            }
            try {
                this.f140b.shutdownInput();
            } catch (Throwable th2) {
                AbstractC0367g.h(th2);
            }
            try {
                this.f140b.close();
            } catch (Throwable th3) {
                AbstractC0367g.h(th3);
            }
        }
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final Object b(InterfaceC0762c interfaceC0762c) throws IOException {
        Socket socketCreateSocket;
        long j4 = this.f125a;
        if (this.f144g) {
            try {
                SSLContext sSLContext = SSLContext.getInstance("TLS");
                sSLContext.init(null, null, new SecureRandom());
                socketCreateSocket = sSLContext.getSocketFactory().createSocket();
            } catch (GeneralSecurityException e) {
                throw new IOException(B1.a.m("Create SSL socket failed: ", e.getMessage()));
            }
        } else {
            socketCreateSocket = new Socket();
        }
        int i4 = (int) j4;
        socketCreateSocket.connect(new InetSocketAddress(this.e, this.f143f), i4);
        socketCreateSocket.setSoTimeout(i4);
        this.f140b = socketCreateSocket;
        new BufferedReader(new InputStreamReader(this.f140b.getInputStream()));
        OutputStream outputStream = this.f140b.getOutputStream();
        i.d(outputStream, "getOutputStream(...)");
        this.f142d = outputStream instanceof BufferedOutputStream ? (BufferedOutputStream) outputStream : new BufferedOutputStream(outputStream, 8192);
        InputStream inputStream = this.f140b.getInputStream();
        i.d(inputStream, "getInputStream(...)");
        this.f141c = inputStream instanceof BufferedInputStream ? (BufferedInputStream) inputStream : new BufferedInputStream(inputStream, 8192);
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final Object c(A3.c cVar) throws IOException {
        this.f142d.flush();
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final boolean d() {
        return this.f140b.isConnected();
    }

    @Override // C1.b
    public final Serializable e(int i4, A3.c cVar) {
        return k(this, i4, cVar);
    }

    @Override // C1.b
    public final Object g(byte[] bArr, A3.c cVar) throws IOException {
        AbstractC0752b.i(this.f141c, bArr);
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final Object h(int i4, A3.c cVar) throws IOException {
        this.f142d.write(i4);
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final Object i(byte[] bArr, int i4, int i5, n nVar) throws IOException {
        this.f142d.write(bArr, i4, i5);
        return w3.i.f6729a;
    }

    @Override // C1.b
    public final Object j(byte[] bArr, A3.c cVar) throws IOException {
        this.f142d.write(bArr);
        return w3.i.f6729a;
    }
}
