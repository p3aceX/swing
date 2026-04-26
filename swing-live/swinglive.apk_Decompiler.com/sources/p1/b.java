package p1;

import android.util.Base64OutputStream;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.zip.GZIPOutputStream;
import org.json.JSONArray;
import org.json.JSONObject;
import u1.C0689b;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class b implements Callable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6179a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ c f6180b;

    public /* synthetic */ b(c cVar, int i4) {
        this.f6179a = i4;
        this.f6180b = cVar;
    }

    @Override // java.util.concurrent.Callable
    public final Object call() {
        String string;
        Set setUnmodifiableSet;
        Set setUnmodifiableSet2;
        switch (this.f6179a) {
            case 0:
                c cVar = this.f6180b;
                synchronized (cVar) {
                    try {
                        g gVar = (g) cVar.f6181a.get();
                        ArrayList arrayListC = gVar.c();
                        gVar.b();
                        JSONArray jSONArray = new JSONArray();
                        for (int i4 = 0; i4 < arrayListC.size(); i4++) {
                            a aVar = (a) arrayListC.get(i4);
                            JSONObject jSONObject = new JSONObject();
                            jSONObject.put("agent", aVar.f6177a);
                            jSONObject.put("dates", new JSONArray((Collection) aVar.f6178b));
                            jSONArray.put(jSONObject);
                        }
                        JSONObject jSONObject2 = new JSONObject();
                        jSONObject2.put("heartbeats", jSONArray);
                        jSONObject2.put("version", "2");
                        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                        Base64OutputStream base64OutputStream = new Base64OutputStream(byteArrayOutputStream, 11);
                        try {
                            GZIPOutputStream gZIPOutputStream = new GZIPOutputStream(base64OutputStream);
                            try {
                                gZIPOutputStream.write(jSONObject2.toString().getBytes("UTF-8"));
                                gZIPOutputStream.close();
                                base64OutputStream.close();
                                string = byteArrayOutputStream.toString("UTF-8");
                            } finally {
                                try {
                                    break;
                                } catch (Throwable th) {
                                }
                            }
                        } finally {
                            try {
                                break;
                            } catch (Throwable th2) {
                            }
                        }
                    } finally {
                    }
                }
                return string;
            default:
                c cVar2 = this.f6180b;
                synchronized (cVar2) {
                    g gVar2 = (g) cVar2.f6181a.get();
                    long jCurrentTimeMillis = System.currentTimeMillis();
                    C0689b c0689b = (C0689b) cVar2.f6183c.get();
                    C0690c c0690c = c0689b.f6638b;
                    synchronized (((HashSet) c0690c.f6642b)) {
                        setUnmodifiableSet = Collections.unmodifiableSet((HashSet) c0690c.f6642b);
                        break;
                    }
                    boolean zIsEmpty = setUnmodifiableSet.isEmpty();
                    String string2 = c0689b.f6637a;
                    if (!zIsEmpty) {
                        StringBuilder sb = new StringBuilder();
                        sb.append(string2);
                        sb.append(' ');
                        synchronized (((HashSet) c0690c.f6642b)) {
                            setUnmodifiableSet2 = Collections.unmodifiableSet((HashSet) c0690c.f6642b);
                            break;
                        }
                        sb.append(C0689b.a(setUnmodifiableSet2));
                        string2 = sb.toString();
                    }
                    gVar2.g(string2, jCurrentTimeMillis);
                }
                return null;
        }
    }
}
