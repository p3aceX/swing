package u1;

import A.C0012l;
import B0.d;
import D2.F;
import D2.M;
import D2.r;
import I.C0053n;
import I.m0;
import I.n0;
import N2.n;
import N2.p;
import O.J;
import O2.f;
import O2.m;
import T3.q;
import V.e;
import X.N;
import android.graphics.Bitmap;
import android.graphics.ColorSpace;
import android.graphics.ImageDecoder;
import android.graphics.Rect;
import android.media.MediaCodec;
import android.media.MediaFormat;
import android.os.Build;
import android.os.Parcel;
import android.util.Log;
import android.util.Size;
import android.view.PointerIcon;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import androidx.profileinstaller.ProfileInstallReceiver;
import com.google.android.gms.common.api.internal.InterfaceC0270s;
import com.google.android.gms.common.internal.v;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.android.gms.internal.base.zac;
import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.android.recaptcha.RecaptchaAction;
import com.google.android.recaptcha.RecaptchaTasksClient;
import e1.i;
import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.view.k;
import j.j;
import j.o;
import j.t;
import java.io.IOException;
import java.io.Serializable;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import k.C0492i;
import u1.C0690c;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: renamed from: u1.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0690c implements InterfaceC0270s, M, f, O2.b, m, d.b, Q1.a, e, i, o, Continuation {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static volatile C0690c f6639c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static C0690c f6640d;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6641a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f6642b;

    public /* synthetic */ C0690c(int i4, boolean z4) {
        this.f6641a = i4;
    }

    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:56:0x00c9  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private final void w(D2.v r13, N2.j r14) {
        /*
            Method dump skipped, instruction units count: 940
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: u1.C0690c.w(D2.v, N2.j):void");
    }

    /* JADX WARN: Removed duplicated region for block: B:16:0x0033  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void A(I.m0 r7) {
        /*
            r6 = this;
            java.lang.String r0 = "newState"
            J3.i.e(r7, r0)
        L5:
            java.lang.Object r0 = r6.f6642b
            T3.q r0 = (T3.q) r0
            r0.getClass()
            z0.j r1 = U3.k.f2122a
            java.util.concurrent.atomic.AtomicReferenceFieldUpdater r2 = T3.q.e
            java.lang.Object r2 = r2.get(r0)
            if (r2 != r1) goto L17
            r2 = 0
        L17:
            r3 = r2
            I.m0 r3 = (I.m0) r3
            boolean r4 = r3 instanceof I.e0
            if (r4 == 0) goto L20
            r4 = 1
            goto L26
        L20:
            I.n0 r4 = I.n0.f709b
            boolean r4 = J3.i.a(r3, r4)
        L26:
            if (r4 == 0) goto L29
            goto L33
        L29:
            boolean r4 = r3 instanceof I.C0043d
            if (r4 == 0) goto L35
            int r4 = r3.f704a
            int r5 = r7.f704a
            if (r5 <= r4) goto L39
        L33:
            r3 = r7
            goto L39
        L35:
            boolean r4 = r3 instanceof I.c0
            if (r4 == 0) goto L47
        L39:
            if (r2 != 0) goto L3c
            r2 = r1
        L3c:
            if (r3 != 0) goto L3f
            goto L40
        L3f:
            r1 = r3
        L40:
            boolean r0 = r0.e(r2, r1)
            if (r0 == 0) goto L5
            return
        L47:
            A0.b r7 = new A0.b
            r7.<init>()
            throw r7
        */
        throw new UnsupportedOperationException("Method not decompiled: u1.C0690c.A(I.m0):void");
    }

    @Override // j.o
    public void a(j jVar, boolean z4) {
        if (jVar instanceof t) {
            ((t) jVar).v.j().c(false);
        }
        o oVar = ((C0492i) this.f6642b).e;
        if (oVar != null) {
            oVar.a(jVar, z4);
        }
    }

    @Override // com.google.android.gms.common.api.internal.InterfaceC0270s
    public void accept(Object obj, Object obj2) {
        B0.a aVar = (B0.a) ((d) obj).getService();
        Parcel parcelZaa = aVar.zaa();
        zac.zac(parcelZaa, (v) this.f6642b);
        aVar.zad(1, parcelZaa);
        ((TaskCompletionSource) obj2).setResult(null);
    }

    @Override // O2.f
    public void b(String str, O2.d dVar, p1.d dVar2) {
        ((F2.i) this.f6642b).b(str, dVar, dVar2);
    }

    @Override // O2.b
    public void d(Object obj, D2.v vVar) {
        HashMap map;
        HashMap map2;
        C0747k c0747k = (C0747k) this.f6642b;
        if (((io.flutter.view.e) c0747k.f6833d) == null) {
            vVar.f(null);
            return;
        }
        map = (HashMap) obj;
        String str = (String) map.get("type");
        map2 = (HashMap) map.get("data");
        str.getClass();
        switch (str) {
            case "tooltip":
                String str2 = (String) map2.get("message");
                if (str2 != null) {
                    io.flutter.view.e eVar = (io.flutter.view.e) c0747k.f6833d;
                    if (Build.VERSION.SDK_INT < 28) {
                        k kVar = (k) eVar.f4703a;
                        AccessibilityEvent accessibilityEventE = kVar.e(0, 32);
                        accessibilityEventE.getText().add(str2);
                        kVar.i(accessibilityEventE);
                    } else {
                        eVar.getClass();
                    }
                    break;
                }
                break;
            case "announce":
                String str3 = (String) map2.get("message");
                if (str3 != null) {
                    io.flutter.view.e eVar2 = (io.flutter.view.e) c0747k.f6833d;
                    if (Build.VERSION.SDK_INT >= 36) {
                        eVar2.getClass();
                        Log.w("AccessibilityBridge", "Using AnnounceSemanticsEvent for accessibility is deprecated on Android. Migrate to using semantic properties for a more robust and accessible user experience.\nFlutter: If you are unsure why you are seeing this bug, it might be because you are using a widget that calls this method. See https://github.com/flutter/flutter/issues/165510 for more details.\nAndroid documentation: https://developer.android.com/reference/android/view/View#announceForAccessibility(java.lang.CharSequence)");
                    }
                    ((k) eVar2.f4703a).f4788a.announceForAccessibility(str3);
                    break;
                }
                break;
            case "tap":
                Integer num = (Integer) map.get("nodeId");
                if (num != null) {
                    io.flutter.view.e eVar3 = (io.flutter.view.e) c0747k.f6833d;
                    ((k) eVar3.f4703a).h(num.intValue(), 1);
                    break;
                }
                break;
            case "focus":
                Integer num2 = (Integer) map.get("nodeId");
                if (num2 != null) {
                    io.flutter.view.e eVar4 = (io.flutter.view.e) c0747k.f6833d;
                    ((k) eVar4.f4703a).h(num2.intValue(), 8);
                    break;
                }
                break;
            case "longPress":
                Integer num3 = (Integer) map.get("nodeId");
                if (num3 != null) {
                    io.flutter.view.e eVar5 = (io.flutter.view.e) c0747k.f6833d;
                    ((k) eVar5.f4703a).h(num3.intValue(), 2);
                    break;
                }
                break;
        }
        vVar.f(null);
    }

    @Override // e1.i
    public Object e(String str) {
        return ((N) this.f6642b).g(str, null);
    }

    @Override // V.e
    public void f(int i4, Serializable serializable) {
        String str;
        switch (i4) {
            case 1:
                str = "RESULT_INSTALL_SUCCESS";
                break;
            case 2:
                str = "RESULT_ALREADY_INSTALLED";
                break;
            case 3:
                str = "RESULT_UNSUPPORTED_ART_VERSION";
                break;
            case 4:
                str = "RESULT_NOT_WRITABLE";
                break;
            case 5:
                str = "RESULT_DESIRED_FORMAT_UNSUPPORTED";
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                str = "RESULT_BASELINE_PROFILE_NOT_FOUND";
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                str = "RESULT_IO_EXCEPTION";
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                str = "RESULT_PARSE_EXCEPTION";
                break;
            case 9:
            default:
                str = "";
                break;
            case 10:
                str = "RESULT_INSTALL_SKIP_FILE_SUCCESS";
                break;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                str = "RESULT_DELETE_SKIP_FILE_SUCCESS";
                break;
        }
        if (i4 == 6 || i4 == 7 || i4 == 8) {
            Log.e("ProfileInstaller", str, (Throwable) serializable);
        } else {
            Log.d("ProfileInstaller", str);
        }
        ((ProfileInstallReceiver) this.f6642b).setResultCode(i4);
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Removed duplicated region for block: B:9:0x0035  */
    @Override // O2.m
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public void g(D2.v r20, N2.j r21) {
        /*
            Method dump skipped, instruction units count: 1040
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: u1.C0690c.g(D2.v, N2.j):void");
    }

    @Override // j.o
    public boolean h(t tVar) {
        if (tVar == null) {
            return false;
        }
        tVar.f5155w.getClass();
        C0492i c0492i = (C0492i) this.f6642b;
        c0492i.getClass();
        o oVar = c0492i.e;
        if (oVar != null) {
            return oVar.h(tVar);
        }
        return false;
    }

    @Override // O2.f
    public void i(String str, ByteBuffer byteBuffer) {
        ((F2.i) this.f6642b).s(str, byteBuffer, null);
    }

    @Override // V.e
    public void j() {
        Log.d("ProfileInstaller", "DIAGNOSTIC_PROFILE_IS_COMPRESSED");
    }

    @Override // d.b
    public void k(Object obj) {
        Map map = (Map) obj;
        ArrayList arrayList = new ArrayList(map.values());
        int[] iArr = new int[arrayList.size()];
        for (int i4 = 0; i4 < arrayList.size(); i4++) {
            iArr[i4] = ((Boolean) arrayList.get(i4)).booleanValue() ? 0 : -1;
        }
        O.N n4 = (O.N) this.f6642b;
        J j4 = (J) n4.f1227E.pollFirst();
        if (j4 == null) {
            Log.w("FragmentManager", "No permissions were requested for " + this);
            return;
        }
        C0053n c0053n = n4.f1239c;
        String str = j4.f1218a;
        if (c0053n.i(str) == null) {
            Log.w("FragmentManager", "Permission request result delivered for unknown Fragment " + str);
        }
    }

    @Override // Q1.a
    public void l(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo) {
        ((S1.a) this.f6642b).f1804k.c(byteBuffer, bufferInfo);
    }

    @Override // O2.f
    public p1.d m(O2.k kVar) {
        return ((F2.i) this.f6642b).m(kVar);
    }

    @Override // D2.M
    public void n() {
        ((D2.N) this.f6642b).f174b = null;
    }

    @Override // O2.f
    public void p(String str, O2.d dVar) {
        ((F2.i) this.f6642b).b(str, dVar, null);
    }

    @Override // D2.M
    public void q(io.flutter.embedding.engine.renderer.j jVar) {
        ((D2.N) this.f6642b).f174b = jVar;
    }

    @Override // Q1.a
    public void r(MediaFormat mediaFormat) {
        ((S1.a) this.f6642b).f1804k.f2094g = mediaFormat;
    }

    @Override // O2.f
    public void s(String str, ByteBuffer byteBuffer, O2.e eVar) {
        ((F2.i) this.f6642b).s(str, byteBuffer, eVar);
    }

    public void t(String str) {
        D2.v vVar = (D2.v) this.f6642b;
        Q2.a aVar = (Q2.a) vVar.f260b;
        if (D2.v.e == null) {
            F f4 = new F();
            f4.put("alias", 1010);
            f4.put("allScroll", 1013);
            f4.put("basic", 1000);
            f4.put("cell", 1006);
            f4.put("click", 1002);
            f4.put("contextMenu", 1001);
            f4.put("copy", 1011);
            f4.put("forbidden", 1012);
            f4.put("grab", 1020);
            f4.put("grabbing", 1021);
            f4.put("help", 1003);
            f4.put("move", 1013);
            f4.put("none", 0);
            f4.put("noDrop", 1012);
            f4.put("precise", 1007);
            f4.put("text", 1008);
            f4.put("resizeColumn", 1014);
            f4.put("resizeDown", 1015);
            f4.put("resizeUpLeft", 1016);
            f4.put("resizeDownRight", 1017);
            f4.put("resizeLeft", 1014);
            f4.put("resizeLeftRight", 1014);
            f4.put("resizeRight", 1014);
            f4.put("resizeRow", 1015);
            f4.put("resizeUp", 1015);
            f4.put("resizeUpDown", 1015);
            f4.put("resizeUpLeft", 1017);
            f4.put("resizeUpRight", 1016);
            f4.put("resizeUpLeftDownRight", 1017);
            f4.put("resizeUpRightDownLeft", 1016);
            f4.put("verticalText", 1009);
            f4.put("wait", 1004);
            f4.put("zoomIn", 1018);
            f4.put("zoomOut", 1019);
            D2.v.e = f4;
        }
        aVar.setPointerIcon(PointerIcon.getSystemIcon(((r) ((Q2.a) vVar.f260b)).getContext(), ((Integer) D2.v.e.getOrDefault(str, 1000)).intValue()));
    }

    @Override // com.google.android.gms.tasks.Continuation
    public /* synthetic */ Object then(Task task) {
        if (task.isSuccessful()) {
            return ((RecaptchaTasksClient) task.getResult()).executeTask((RecaptchaAction) this.f6642b);
        }
        Exception exception = task.getException();
        com.google.android.gms.common.internal.F.g(exception);
        if (!(exception instanceof k1.o)) {
            return Tasks.forException(exception);
        }
        if (Log.isLoggable("RecaptchaHandler", 4)) {
            Log.i("RecaptchaHandler", "Ignoring error related to fetching recaptcha config - " + exception.getMessage());
        }
        return Tasks.forResult("");
    }

    /* JADX WARN: Type inference failed for: r3v2, types: [H2.a] */
    public Bitmap u(ByteBuffer byteBuffer, H2.d dVar) {
        try {
            return ImageDecoder.decodeBitmap(ImageDecoder.createSource(byteBuffer), new ImageDecoder.OnHeaderDecodedListener() { // from class: H2.a
                @Override // android.graphics.ImageDecoder.OnHeaderDecodedListener
                public final void onHeaderDecoded(ImageDecoder imageDecoder, ImageDecoder.ImageInfo imageInfo, ImageDecoder.Source source) {
                    C0690c c0690c = this.f527a;
                    c0690c.getClass();
                    ColorSpace.Named unused = ColorSpace.Named.SRGB;
                    imageDecoder.setTargetColorSpace(ColorSpace.get(ColorSpace.Named.SRGB));
                    imageDecoder.setAllocator(1);
                    E2.i iVar = (E2.i) c0690c.f6642b;
                    if (iVar != null) {
                        Size size = imageInfo.getSize();
                        FlutterJNI.nativeImageHeaderCallback(iVar.f379a, size.getWidth(), size.getHeight());
                    }
                }
            });
        } catch (IOException e) {
            Log.e("FlutterImageDecoderImplDefault", "Failed to decode image", e);
            return null;
        }
    }

    public m0 v() {
        q qVar = (q) this.f6642b;
        qVar.getClass();
        C0779j c0779j = U3.k.f2122a;
        Object obj = q.e.get(qVar);
        if (obj == c0779j) {
            obj = null;
        }
        return (m0) obj;
    }

    public void x(int i4, n nVar) {
        io.flutter.plugin.editing.i iVar = (io.flutter.plugin.editing.i) this.f6642b;
        iVar.d();
        iVar.f4590f = nVar;
        iVar.e = new C0012l(2, i4);
        iVar.f4592h.e(iVar);
        C0053n c0053n = nVar.f1187j;
        iVar.f4592h = new io.flutter.plugin.editing.f(c0053n != null ? (p) c0053n.f708d : null, iVar.f4586a);
        iVar.e(nVar);
        iVar.f4593i = true;
        if (iVar.e.f55b == 3) {
            iVar.f4600p = false;
        }
        iVar.f4597m = null;
        iVar.f4592h.a(iVar);
    }

    public void y(double d5, double d6, double[] dArr) {
        io.flutter.plugin.editing.i iVar = (io.flutter.plugin.editing.i) this.f6642b;
        iVar.getClass();
        double[] dArr2 = new double[4];
        boolean z4 = dArr[3] == 0.0d && dArr[7] == 0.0d && dArr[15] == 1.0d;
        double d7 = dArr[12];
        double d8 = dArr[15];
        double d9 = d7 / d8;
        dArr2[1] = d9;
        dArr2[0] = d9;
        double d10 = dArr[13] / d8;
        dArr2[3] = d10;
        dArr2[2] = d10;
        Y.f fVar = new Y.f(z4, dArr, dArr2);
        fVar.a(d5, 0.0d);
        fVar.a(d5, d6);
        fVar.a(0.0d, d6);
        double d11 = iVar.f4586a.getContext().getResources().getDisplayMetrics().density;
        iVar.f4597m = new Rect((int) (dArr2[0] * d11), (int) (dArr2[2] * d11), (int) Math.ceil(dArr2[1] * d11), (int) Math.ceil(dArr2[3] * d11));
    }

    public void z(p pVar) {
        p pVar2;
        int i4;
        int i5;
        io.flutter.plugin.editing.i iVar = (io.flutter.plugin.editing.i) this.f6642b;
        View view = iVar.f4586a;
        if (!iVar.f4593i && (pVar2 = iVar.f4599o) != null && (i4 = pVar2.f1197d) >= 0 && (i5 = pVar2.e) > i4) {
            int i6 = i5 - i4;
            int i7 = pVar.e;
            int i8 = pVar.f1197d;
            boolean z4 = true;
            if (i6 == i7 - i8) {
                int i9 = 0;
                while (true) {
                    if (i9 >= i6) {
                        z4 = false;
                        break;
                    } else if (pVar2.f1194a.charAt(i9 + i4) != pVar.f1194a.charAt(i9 + i8)) {
                        break;
                    } else {
                        i9++;
                    }
                }
            }
            iVar.f4593i = z4;
        }
        iVar.f4599o = pVar;
        iVar.f4592h.f(pVar);
        if (iVar.f4593i) {
            iVar.f4587b.restartInput(view);
            iVar.f4593i = false;
        }
    }

    public /* synthetic */ C0690c(Object obj, int i4) {
        this.f6641a = i4;
        this.f6642b = obj;
    }

    public C0690c(int i4) {
        this.f6641a = i4;
        switch (i4) {
            case 3:
                this.f6642b = new HashMap();
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                this.f6642b = new q(n0.f709b);
                break;
            default:
                this.f6642b = new HashSet();
                break;
        }
    }

    public C0690c(f fVar) {
        this.f6641a = 8;
        this.f6642b = new C0053n(fVar, "flutter/keyevent", O2.j.f1453a, null, 5);
    }

    public C0690c(F2.b bVar) {
        this.f6641a = 12;
        new C0747k(bVar, "flutter/scribe", O2.k.f1454a, 11).Y(new B.k(this, 10));
    }

    @Override // D2.M
    public void c() {
    }

    @Override // Q1.a
    public void o(ByteBuffer byteBuffer, ByteBuffer byteBuffer2, ByteBuffer byteBuffer3) {
    }
}
