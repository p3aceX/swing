package y2;

import Q3.D;
import Q3.F;
import Q3.O;
import android.util.Log;
import e1.AbstractC0367g;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URI;
import javax.net.ssl.SSLSocketFactory;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
public final class p extends A3.j implements I3.p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6931a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Y0.n f6932b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ String f6933c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ N2.j f6934d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public p(Y0.n nVar, String str, N2.j jVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.f6932b = nVar;
        this.f6933c = str;
        this.f6934d = jVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new p(this.f6932b, this.f6933c, this.f6934d, interfaceC0762c);
    }

    @Override // I3.p
    public final Object invoke(Object obj, Object obj2) {
        return ((p) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(w3.i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.f6931a;
        if (i4 == 0) {
            AbstractC0367g.M(obj);
            String str = this.f6933c;
            int i5 = -1;
            try {
                boolean zF0 = P3.m.F0(str, "rtmps://");
                URI uri = new URI(P3.m.A0(P3.m.A0(str, "rtmps://", "https://"), "rtmp://", "http://"));
                String host = uri.getHost();
                if (host != null) {
                    int port = uri.getPort() != -1 ? uri.getPort() : zF0 ? 443 : 1935;
                    long jCurrentTimeMillis = System.currentTimeMillis();
                    Socket socketCreateSocket = (zF0 || port == 443) ? SSLSocketFactory.getDefault().createSocket() : new Socket();
                    socketCreateSocket.connect(new InetSocketAddress(host, port), 3000);
                    int iCurrentTimeMillis = (int) (System.currentTimeMillis() - jCurrentTimeMillis);
                    socketCreateSocket.close();
                    i5 = iCurrentTimeMillis;
                }
            } catch (Exception e) {
                Log.e("StreamingPlugin", "Latency check failed", e);
            }
            X3.e eVar = O.f1596a;
            R3.d dVar = V3.o.f2244a;
            o oVar = new o(this.f6934d, i5, null);
            this.f6931a = 1;
            if (F.B(dVar, oVar, this) == enumC0789a) {
                return enumC0789a;
            }
        } else {
            if (i4 != 1) {
                throw new IllegalStateException("call to 'resume' before 'invoke' with coroutine");
            }
            AbstractC0367g.M(obj);
        }
        return w3.i.f6729a;
    }
}
