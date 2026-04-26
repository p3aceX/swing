package D2;

import Q3.O;
import Q3.y0;
import T2.C0158c;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.view.View;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.swing.live.MainActivity;
import com.swing.live.StreamForegroundService;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.atomic.AtomicReference;
import m3.InterfaceC0556c;
import org.json.JSONException;
import org.json.JSONObject;
import u1.C0689b;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class u implements O2.c, T2.q, l1.d, InterfaceC0556c, O2.m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f256a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f257b;

    public /* synthetic */ u(Object obj, int i4) {
        this.f256a = i4;
        this.f257b = obj;
    }

    @Override // m3.InterfaceC0556c
    public boolean a(View view) {
        int i4 = 0;
        while (true) {
            Class[] clsArr = (Class[]) this.f257b;
            if (i4 >= clsArr.length) {
                return false;
            }
            if (clsArr[i4].isInstance(view)) {
                return true;
            }
            i4++;
        }
    }

    @Override // T2.q
    public void b(String str) {
        switch (this.f256a) {
            case 3:
                ((T2.t) this.f257b).a(new T2.v(null, "setFocusPointFailed", "Could not set focus point."));
                break;
            case 4:
                ((T2.t) this.f257b).a(new T2.v(null, "setExposureOffsetFailed", "Could not set exposure offset."));
                break;
            case 5:
                ((T2.t) this.f257b).a(new T2.v(null, "setExposureModeFailed", "Could not set exposure mode."));
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                ((T2.t) this.f257b).a(new T2.v(null, "setFlashModeFailed", "Could not set flash mode."));
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                ((T2.t) this.f257b).a(new T2.v(null, "setExposurePointFailed", "Could not set exposure point."));
                break;
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                ((T2.t) this.f257b).a(new T2.v(null, "setZoomLevelFailed", "Could not set zoom level."));
                break;
            default:
                ((C0158c) this.f257b).f1934c.f1946h.W(str);
                break;
        }
    }

    @Override // l1.d
    public Object e(R0.k kVar) {
        switch (this.f256a) {
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return this.f257b;
            default:
                return new p1.c((Context) kVar.a(Context.class), ((g1.f) kVar.a(g1.f.class)).e(), kVar.d(l1.r.a(p1.d.class)), kVar.c(C0689b.class), (Executor) kVar.b((l1.r) this.f257b));
        }
    }

    @Override // O2.c
    public void f(Object obj) {
        boolean z4 = false;
        if (obj != null) {
            try {
                z4 = ((JSONObject) obj).getBoolean("handled");
            } catch (JSONException e) {
                Log.e("KeyEventChannel", "Unable to unpack JSON message: " + e);
            }
        }
        ((B) ((u) this.f257b).f257b).a(z4);
    }

    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    @Override // O2.m
    public void g(v vVar, N2.j jVar) {
        y2.g gVar;
        y2.g gVar2;
        y2.g gVar3;
        S1.a aVar;
        y2.g gVar4;
        y2.g gVar5;
        y2.g gVar6;
        y2.g gVar7;
        y2.g gVar8;
        int i4 = 2;
        Y0.n nVar = (Y0.n) this.f257b;
        J3.i.e(vVar, "call");
        String str = (String) vVar.f260b;
        if (str != null) {
            lVarD = null;
            y2.l lVarD = null;
            dValueOf = null;
            Double dValueOf = null;
            dValueOf = null;
            Double dValueOf2 = null;
            switch (str.hashCode()) {
                case -1866158462:
                    if (str.equals("startStream")) {
                        Object obj = vVar.f261c;
                        Map map = obj instanceof Map ? (Map) obj : null;
                        if (map == null) {
                            jVar.a(null, "INVALID_ARGS", "Arguments required");
                            return;
                        }
                        Object obj2 = map.get("rtmpsUrl");
                        String str2 = obj2 instanceof String ? (String) obj2 : null;
                        if (str2 == null) {
                            jVar.a(null, "INVALID_ARGS", "rtmpsUrl required");
                            return;
                        }
                        Log.d("StreamingPlugin", "startStream requested for URL: ".concat(str2));
                        Object obj3 = map.get("width");
                        Integer num = obj3 instanceof Integer ? (Integer) obj3 : null;
                        int iIntValue = num != null ? num.intValue() : 1280;
                        Object obj4 = map.get("height");
                        Integer num2 = obj4 instanceof Integer ? (Integer) obj4 : null;
                        int iIntValue2 = num2 != null ? num2.intValue() : 720;
                        Object obj5 = map.get("fps");
                        Integer num3 = obj5 instanceof Integer ? (Integer) obj5 : null;
                        int iIntValue3 = num3 != null ? num3.intValue() : 30;
                        Object obj6 = map.get("videoBitrate");
                        Integer num4 = obj6 instanceof Integer ? (Integer) obj6 : null;
                        int iIntValue4 = num4 != null ? num4.intValue() : 3000;
                        Object obj7 = map.get("audioBitrate");
                        Integer num5 = obj7 instanceof Integer ? (Integer) obj7 : null;
                        int iIntValue5 = num5 != null ? num5.intValue() : 128;
                        Object obj8 = map.get("cameraFacing");
                        Integer num6 = obj8 instanceof Integer ? (Integer) obj8 : null;
                        int iIntValue6 = num6 != null ? num6.intValue() : 0;
                        Object obj9 = map.get("enableAudio");
                        Boolean bool = obj9 instanceof Boolean ? (Boolean) obj9 : null;
                        boolean zBooleanValue = bool != null ? bool.booleanValue() : true;
                        Object obj10 = map.get("overlayEnabled");
                        Boolean bool2 = obj10 instanceof Boolean ? (Boolean) obj10 : null;
                        boolean zBooleanValue2 = bool2 != null ? bool2.booleanValue() : true;
                        y2.k kVar = (y2.k) nVar.f2492f;
                        if (kVar == null) {
                            jVar.a(null, "NO_PREVIEW", "Stream preview view not initialized");
                            return;
                        }
                        kVar.f6918f = new M1.b(nVar, 8);
                        y2.m mVar = new y2.m(nVar, 0);
                        y2.m mVar2 = new y2.m(nVar, 1);
                        kVar.f6919g = mVar;
                        kVar.f6920h = mVar2;
                        try {
                            if (!kVar.b(str2, iIntValue, iIntValue2, iIntValue3, iIntValue4, iIntValue5, iIntValue6, zBooleanValue, zBooleanValue2)) {
                                jVar.a(null, "STREAM_START_FAILED", "Failed to start stream engine");
                                return;
                            }
                            int i5 = StreamForegroundService.f3872a;
                            MainActivity mainActivity = (MainActivity) nVar.f2488a;
                            J3.i.e(mainActivity, "context");
                            Intent intent = new Intent(mainActivity, (Class<?>) StreamForegroundService.class);
                            if (Build.VERSION.SDK_INT >= 26) {
                                mainActivity.startForegroundService(intent);
                            } else {
                                mainActivity.startService(intent);
                            }
                            jVar.c(Boolean.TRUE);
                            return;
                        } catch (Exception e) {
                            String message = e.getMessage();
                            if (message == null) {
                                message = "Encoder error";
                            }
                            jVar.a(null, "STREAM_START_FAILED", message);
                            return;
                        }
                    }
                    break;
                case -1546958959:
                    if (str.equals("updateOverlayData")) {
                        Object obj11 = vVar.f261c;
                        Map map2 = obj11 instanceof Map ? (Map) obj11 : null;
                        if (map2 == null) {
                            jVar.a(null, "INVALID_ARGS", "Overlay data map required");
                            return;
                        }
                        y2.k kVar2 = (y2.k) nVar.f2492f;
                        if (kVar2 != null && (gVar = kVar2.e) != null && !map2.equals(gVar.f6903u)) {
                            gVar.f6903u = map2;
                            if (gVar.f6907z) {
                                gVar.f6885b.post(new y2.b(gVar, i4));
                            }
                        }
                        jVar.c(Boolean.TRUE);
                        return;
                    }
                    break;
                case -1482839869:
                    if (str.equals("setOverlayStyle")) {
                        Object obj12 = vVar.f261c;
                        String str3 = obj12 instanceof String ? (String) obj12 : null;
                        if (str3 == null) {
                            jVar.a(null, "INVALID_ARGS", "Overlay style required");
                            return;
                        }
                        y2.k kVar3 = (y2.k) nVar.f2492f;
                        if (kVar3 != null && (gVar2 = kVar3.e) != null) {
                            gVar2.e(str3);
                        }
                        jVar.c(Boolean.TRUE);
                        return;
                    }
                    break;
                case -1349076446:
                    if (str.equals("stopStream")) {
                        y2.k kVar4 = (y2.k) nVar.f2492f;
                        if (kVar4 != null && (gVar3 = kVar4.e) != null && (aVar = gVar3.f6891i) != null) {
                            try {
                                y0 y0Var = gVar3.f6904w;
                                if (y0Var != null) {
                                    y0Var.a(null);
                                }
                                y0 y0Var2 = gVar3.f6905x;
                                if (y0Var2 != null) {
                                    y0Var2.a(null);
                                }
                                gVar3.a(false);
                                aVar.g();
                                aVar.f();
                                gVar3.f6892j.set(false);
                                gVar3.f6893k.set(false);
                                gVar3.f6896n.set(0L);
                                gVar3.f6879A = false;
                            } catch (Exception e4) {
                                Log.e("EliteStreamManager", "Error stopping stream", e4);
                            }
                            break;
                        }
                        int i6 = StreamForegroundService.f3872a;
                        MainActivity mainActivity2 = (MainActivity) nVar.f2488a;
                        J3.i.e(mainActivity2, "context");
                        mainActivity2.stopService(new Intent(mainActivity2, (Class<?>) StreamForegroundService.class));
                        jVar.c(Boolean.TRUE);
                        return;
                    }
                    break;
                case -905806203:
                    if (str.equals("setMic")) {
                        Object obj13 = vVar.f261c;
                        Boolean bool3 = obj13 instanceof Boolean ? (Boolean) obj13 : null;
                        boolean zBooleanValue3 = bool3 != null ? bool3.booleanValue() : true;
                        y2.k kVar5 = (y2.k) nVar.f2492f;
                        if (kVar5 != null && (gVar4 = kVar5.e) != null) {
                            S1.a aVar2 = gVar4.f6891i;
                            if (zBooleanValue3) {
                                if (aVar2 != null) {
                                    aVar2.f1798d.f524h = false;
                                }
                            } else if (aVar2 != null) {
                                aVar2.f1798d.f524h = true;
                            }
                        }
                        jVar.c(Boolean.TRUE);
                        return;
                    }
                    break;
                case -696286120:
                    if (str.equals("zoomIn")) {
                        y2.k kVar6 = (y2.k) nVar.f2492f;
                        if (kVar6 != null) {
                            y2.g gVar9 = kVar6.e;
                            if ((gVar9 != null ? gVar9.g(0.12f) : null) != null) {
                                dValueOf2 = Double.valueOf(r0.floatValue());
                            }
                        }
                        jVar.c(dValueOf2);
                        return;
                    }
                    break;
                case -198818742:
                    if (str.equals("checkNetworkPerformance")) {
                        Object obj14 = vVar.f261c;
                        Map map3 = obj14 instanceof Map ? (Map) obj14 : null;
                        Object obj15 = map3 != null ? map3.get("rtmpsUrl") : null;
                        String str4 = obj15 instanceof String ? (String) obj15 : null;
                        if (str4 == null) {
                            jVar.a(null, "INVALID_ARGS", "rtmpsUrl required");
                            return;
                        }
                        V3.d dVar = (V3.d) nVar.e;
                        X3.e eVar = O.f1596a;
                        Q3.F.s(dVar, X3.d.f2437c, new y2.p(nVar, str4, jVar, null), 2);
                        return;
                    }
                    break;
                case -110027141:
                    if (str.equals("zoomOut")) {
                        y2.k kVar7 = (y2.k) nVar.f2492f;
                        if (kVar7 != null) {
                            y2.g gVar10 = kVar7.e;
                            if ((gVar10 != null ? gVar10.g(-0.12f) : null) != null) {
                                dValueOf = Double.valueOf(r0.floatValue());
                            }
                        }
                        jVar.c(dValueOf);
                        return;
                    }
                    break;
                case 394317524:
                    if (str.equals("testUploadSpeed")) {
                        Object obj16 = vVar.f261c;
                        Map map4 = obj16 instanceof Map ? (Map) obj16 : null;
                        Object obj17 = map4 != null ? map4.get("rtmpsUrl") : null;
                        String str5 = obj17 instanceof String ? (String) obj17 : null;
                        if (str5 == null) {
                            jVar.a(null, "INVALID_ARGS", "rtmpsUrl required");
                            return;
                        }
                        V3.d dVar2 = (V3.d) nVar.e;
                        X3.e eVar2 = O.f1596a;
                        Q3.F.s(dVar2, X3.d.f2437c, new y2.r(nVar, str5, jVar, null), 2);
                        return;
                    }
                    break;
                case 418819410:
                    if (str.equals("setScreenDimmed")) {
                        Object obj18 = vVar.f261c;
                        Boolean bool4 = obj18 instanceof Boolean ? (Boolean) obj18 : null;
                        boolean zBooleanValue4 = bool4 != null ? bool4.booleanValue() : false;
                        y2.k kVar8 = (y2.k) nVar.f2492f;
                        if (kVar8 != null && (gVar5 = kVar8.e) != null) {
                            gVar5.a(zBooleanValue4);
                        }
                        jVar.c(Boolean.TRUE);
                        return;
                    }
                    break;
                case 767111033:
                    if (str.equals("switchCamera")) {
                        y2.k kVar9 = (y2.k) nVar.f2492f;
                        if (kVar9 != null && (gVar6 = kVar9.e) != null) {
                            S1.a aVar3 = gVar6.f6891i;
                            if (aVar3 != null) {
                                aVar3.h();
                            }
                            AtomicReference atomicReference = gVar6.f6898p;
                            Object obj19 = atomicReference.get();
                            M1.g gVar11 = M1.g.f1084a;
                            if (obj19 == gVar11) {
                                gVar11 = M1.g.f1085b;
                            }
                            atomicReference.set(gVar11);
                        }
                        jVar.c(Boolean.TRUE);
                        return;
                    }
                    break;
                case 862804568:
                    if (str.equals("isStreaming")) {
                        y2.k kVar10 = (y2.k) nVar.f2492f;
                        jVar.c(Boolean.valueOf((kVar10 == null || (gVar7 = kVar10.e) == null) ? false : gVar7.f6892j.get()));
                        return;
                    }
                    break;
                case 1965583081:
                    if (str.equals("getStats")) {
                        y2.k kVar11 = (y2.k) nVar.f2492f;
                        if (kVar11 != null && (gVar8 = kVar11.e) != null) {
                            lVarD = gVar8.d();
                        }
                        if (lVarD != null) {
                            jVar.c(x3.s.d0(new w3.c("bitrate", Long.valueOf(lVarD.f6921a)), new w3.c("fps", Integer.valueOf(lVarD.f6922b)), new w3.c("droppedFrames", Integer.valueOf(lVarD.f6923c)), new w3.c("isConnected", Boolean.valueOf(lVarD.f6924d)), new w3.c("elapsedSeconds", Long.valueOf(lVarD.e))));
                            return;
                        } else {
                            jVar.c(x3.s.d0(new w3.c("bitrate", 0L), new w3.c("fps", 0), new w3.c("droppedFrames", 0), new w3.c("isConnected", Boolean.FALSE), new w3.c("elapsedSeconds", 0L)));
                            return;
                        }
                    }
                    break;
            }
        }
        jVar.b();
    }
}
