package io.flutter.plugin.platform;

import D2.AbstractActivityC0029d;
import D2.K;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.res.AssetFileDescriptor;
import android.hardware.display.DisplayManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.util.SparseArray;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;
import com.google.crypto.tink.shaded.protobuf.S;
import io.flutter.view.TextureRegistry$SurfaceProducer;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public final class n implements N2.i, h {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4646a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Object f4647b;

    public /* synthetic */ n(Object obj, int i4) {
        this.f4646a = i4;
        this.f4647b = obj;
    }

    @Override // N2.i
    public void a(int i4) {
        FrameLayout frameLayoutA;
        switch (this.f4646a) {
            case 0:
                q qVar = (q) this.f4647b;
                if (qVar.m(i4)) {
                    frameLayoutA = ((C) qVar.f4674p.get(Integer.valueOf(i4))).a();
                } else {
                    g gVar = (g) qVar.f4676r.get(i4);
                    if (gVar == null) {
                        S.j("Clearing focus on an unknown view with id: ", i4, "PlatformViewsController");
                    } else {
                        frameLayoutA = ((y2.k) gVar).f6916c;
                    }
                }
                if (frameLayoutA != null) {
                    frameLayoutA.clearFocus();
                } else {
                    S.j("Clearing focus on a null view with id: ", i4, "PlatformViewsController");
                }
                break;
            default:
                g gVar2 = (g) ((p) this.f4647b).f4655o.get(i4);
                if (gVar2 != null) {
                    FrameLayout frameLayout = ((y2.k) gVar2).f6916c;
                    if (frameLayout != null) {
                        frameLayout.clearFocus();
                    } else {
                        S.j("Clearing focus on a null view with id: ", i4, "PlatformViewsController2");
                    }
                } else {
                    S.j("Clearing focus on an unknown view with id: ", i4, "PlatformViewsController2");
                }
                break;
        }
    }

    @Override // io.flutter.plugin.platform.h
    public long b() {
        return ((TextureRegistry$SurfaceProducer) this.f4647b).id();
    }

    @Override // N2.i
    public void c(N2.e eVar) {
        q qVar = (q) this.f4647b;
        qVar.getClass();
        q.e(19);
        q.a(qVar, eVar);
        if (qVar.e.IsSurfaceControlEnabled()) {
            throw new IllegalStateException("Trying to create a Hybrid Composition view with HC++ enabled.");
        }
        qVar.b(eVar, false);
        q.e(19);
        if (qVar.e.IsSurfaceControlEnabled()) {
            throw new IllegalStateException("Trying to create a Hybrid Composition view with HC++ enabled.");
        }
    }

    @Override // io.flutter.plugin.platform.h
    public void d(int i4, int i5) {
        ((TextureRegistry$SurfaceProducer) this.f4647b).setSize(i4, i5);
    }

    @Override // N2.i
    public void e(boolean z4) {
        ((q) this.f4647b).f4681x = z4;
    }

    public CharSequence f(N2.c cVar) {
        AbstractActivityC0029d abstractActivityC0029d = (AbstractActivityC0029d) ((f) this.f4647b).f4627b;
        ClipboardManager clipboardManager = (ClipboardManager) abstractActivityC0029d.getSystemService("clipboard");
        CharSequence charSequence = null;
        if (clipboardManager.hasPrimaryClip()) {
            try {
                try {
                    ClipData primaryClip = clipboardManager.getPrimaryClip();
                    if (primaryClip != null) {
                        if (cVar != null) {
                            if (cVar == N2.c.f1133a) {
                            }
                        }
                        ClipData.Item itemAt = primaryClip.getItemAt(0);
                        CharSequence text = itemAt.getText();
                        if (text != null) {
                            return text;
                        }
                        try {
                            Uri uri = itemAt.getUri();
                            if (uri == null) {
                                Log.w("PlatformPlugin", "Clipboard item contained no textual content nor a URI to retrieve it from.");
                                return null;
                            }
                            String scheme = uri.getScheme();
                            if (!scheme.equals("content")) {
                                Log.w("PlatformPlugin", "Clipboard item contains a Uri with scheme '" + scheme + "'that is unhandled.");
                                return null;
                            }
                            AssetFileDescriptor assetFileDescriptorOpenTypedAssetFileDescriptor = abstractActivityC0029d.getContentResolver().openTypedAssetFileDescriptor(uri, "text/*", null);
                            CharSequence charSequenceCoerceToText = itemAt.coerceToText(abstractActivityC0029d);
                            if (assetFileDescriptorOpenTypedAssetFileDescriptor == null) {
                                return charSequenceCoerceToText;
                            }
                            try {
                                assetFileDescriptorOpenTypedAssetFileDescriptor.close();
                                return charSequenceCoerceToText;
                            } catch (IOException e) {
                                charSequence = charSequenceCoerceToText;
                                e = e;
                                Log.w("PlatformPlugin", "Failed to close AssetFileDescriptor while trying to read text from URI.", e);
                                return charSequence;
                            }
                        } catch (IOException e4) {
                            e = e4;
                            charSequence = text;
                        }
                    }
                } catch (IOException e5) {
                    e = e5;
                }
            } catch (FileNotFoundException unused) {
                Log.w("PlatformPlugin", "Clipboard text was unable to be received from content URI.");
                return charSequence;
            } catch (SecurityException e6) {
                Log.w("PlatformPlugin", "Attempted to get clipboard data that requires additional permission(s).\nSee the exception details for which permission(s) are required, and consider adding them to your Android Manifest as described in:\nhttps://developer.android.com/guide/topics/permissions/overview", e6);
                return charSequence;
            }
        }
        return null;
    }

    public void g(ArrayList arrayList) {
        f fVar = (f) this.f4647b;
        fVar.getClass();
        int i4 = arrayList.isEmpty() ? 5894 : 1798;
        for (int i5 = 0; i5 < arrayList.size(); i5++) {
            int iOrdinal = ((N2.d) arrayList.get(i5)).ordinal();
            if (iOrdinal == 0) {
                i4 &= -5;
            } else if (iOrdinal == 1) {
                i4 &= -515;
            }
        }
        fVar.f4626a = i4;
        fVar.d();
    }

    @Override // io.flutter.plugin.platform.h
    public int getHeight() {
        return ((TextureRegistry$SurfaceProducer) this.f4647b).getHeight();
    }

    @Override // io.flutter.plugin.platform.h
    public Surface getSurface() {
        return ((TextureRegistry$SurfaceProducer) this.f4647b).getSurface();
    }

    @Override // io.flutter.plugin.platform.h
    public int getWidth() {
        return ((TextureRegistry$SurfaceProducer) this.f4647b).getWidth();
    }

    public void h(int i4) {
        View decorView = ((AbstractActivityC0029d) ((f) this.f4647b).f4627b).getWindow().getDecorView();
        switch (K.j.b(i4)) {
            case 0:
                decorView.performHapticFeedback(0);
                break;
            case 1:
                decorView.performHapticFeedback(1);
                break;
            case 2:
                decorView.performHapticFeedback(3);
                break;
            case 3:
                decorView.performHapticFeedback(6);
                break;
            case 4:
                decorView.performHapticFeedback(4);
                break;
            case 5:
                if (Build.VERSION.SDK_INT >= 30) {
                    decorView.performHapticFeedback(16);
                }
                break;
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                if (Build.VERSION.SDK_INT >= 30) {
                    decorView.performHapticFeedback(3);
                }
                break;
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                if (Build.VERSION.SDK_INT >= 30) {
                    decorView.performHapticFeedback(17);
                }
                break;
        }
    }

    @Override // N2.i
    public void j(int i4, double d5, double d6) {
        q qVar = (q) this.f4647b;
        if (qVar.m(i4)) {
            return;
        }
        i iVar = (i) qVar.f4679u.get(i4);
        if (iVar == null) {
            S.j("Setting offset for unknown platform view with id: ", i4, "PlatformViewsController");
            return;
        }
        int iN = qVar.n(d5);
        int iN2 = qVar.n(d6);
        FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) iVar.getLayoutParams();
        layoutParams.topMargin = iN;
        layoutParams.leftMargin = iN2;
        iVar.setLayoutParams(layoutParams);
    }

    @Override // N2.i
    public void k(int i4, int i5) {
        FrameLayout frameLayoutA;
        switch (this.f4646a) {
            case 0:
                if (i5 != 0 && i5 != 1) {
                    throw new IllegalStateException("Trying to set unknown direction value: " + i5 + "(view id: " + i4 + ")");
                }
                q qVar = (q) this.f4647b;
                if (qVar.m(i4)) {
                    frameLayoutA = ((C) qVar.f4674p.get(Integer.valueOf(i4))).a();
                } else {
                    g gVar = (g) qVar.f4676r.get(i4);
                    if (gVar == null) {
                        S.j("Setting direction to an unknown view with id: ", i4, "PlatformViewsController");
                        return;
                    }
                    frameLayoutA = ((y2.k) gVar).f6916c;
                }
                if (frameLayoutA == null) {
                    S.j("Setting direction to a null view with id: ", i4, "PlatformViewsController");
                    return;
                } else {
                    frameLayoutA.setLayoutDirection(i5);
                    return;
                }
            default:
                g gVar2 = (g) ((p) this.f4647b).f4655o.get(i4);
                if (gVar2 == null) {
                    S.j("Setting direction to an unknown view with id: ", i4, "PlatformViewsController2");
                    return;
                }
                FrameLayout frameLayout = ((y2.k) gVar2).f6916c;
                if (frameLayout == null) {
                    S.j("Setting direction to a null view with id: ", i4, "PlatformViewsController2");
                    return;
                } else {
                    frameLayout.setLayoutDirection(i5);
                    return;
                }
        }
    }

    /* JADX WARN: Removed duplicated region for block: B:28:0x00bd  */
    /* JADX WARN: Type inference failed for: r14v2, types: [io.flutter.plugin.platform.l] */
    @Override // N2.i
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public long l(final N2.e r25) {
        /*
            Method dump skipped, instruction units count: 440
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: io.flutter.plugin.platform.n.l(N2.e):long");
    }

    @Override // N2.i
    public void p(int i4) {
        J2.a aVar;
        ViewGroup viewGroup;
        ViewGroup viewGroup2;
        switch (this.f4646a) {
            case 0:
                q qVar = (q) this.f4647b;
                g gVar = (g) qVar.f4676r.get(i4);
                if (gVar != null) {
                    FrameLayout frameLayout = ((y2.k) gVar).f6916c;
                    if (frameLayout != null && (viewGroup = (ViewGroup) frameLayout.getParent()) != null) {
                        viewGroup.removeView(frameLayout);
                    }
                    qVar.f4676r.remove(i4);
                    try {
                        ((y2.k) gVar).a();
                    } catch (RuntimeException e) {
                        Log.e("PlatformViewsController", "Disposing platform view threw an exception", e);
                    }
                    if (!qVar.m(i4)) {
                        SparseArray sparseArray = qVar.f4679u;
                        i iVar = (i) sparseArray.get(i4);
                        if (iVar == null) {
                            SparseArray sparseArray2 = qVar.f4677s;
                            J2.b bVar = (J2.b) sparseArray2.get(i4);
                            if (bVar != null) {
                                bVar.removeAllViews();
                                bVar.a();
                                ViewGroup viewGroup3 = (ViewGroup) bVar.getParent();
                                if (viewGroup3 != null) {
                                    viewGroup3.removeView(bVar);
                                }
                                sparseArray2.remove(i4);
                            }
                        } else {
                            iVar.removeAllViews();
                            h hVar = iVar.f4634f;
                            if (hVar != null) {
                                hVar.release();
                                iVar.f4634f = null;
                            }
                            ViewTreeObserver viewTreeObserver = iVar.getViewTreeObserver();
                            if (viewTreeObserver.isAlive() && (aVar = iVar.f4635m) != null) {
                                iVar.f4635m = null;
                                viewTreeObserver.removeOnGlobalFocusChangeListener(aVar);
                            }
                            ViewGroup viewGroup4 = (ViewGroup) iVar.getParent();
                            if (viewGroup4 != null) {
                                viewGroup4.removeView(iVar);
                            }
                            sparseArray.remove(i4);
                        }
                    } else {
                        HashMap map = qVar.f4674p;
                        C c5 = (C) map.get(Integer.valueOf(i4));
                        FrameLayout frameLayoutA = c5.a();
                        if (frameLayoutA != null) {
                            qVar.f4675q.remove(frameLayoutA.getContext());
                        }
                        c5.f4607a.cancel();
                        c5.f4607a.detachState();
                        c5.f4613h.release();
                        c5.f4611f.release();
                        map.remove(Integer.valueOf(i4));
                    }
                } else {
                    S.j("Disposing unknown platform view with id: ", i4, "PlatformViewsController");
                }
                break;
            default:
                p pVar = (p) this.f4647b;
                g gVar2 = (g) pVar.f4655o.get(i4);
                if (gVar2 != null) {
                    FrameLayout frameLayout2 = ((y2.k) gVar2).f6916c;
                    if (frameLayout2 != null && (viewGroup2 = (ViewGroup) frameLayout2.getParent()) != null) {
                        viewGroup2.removeView(frameLayout2);
                    }
                    pVar.f4655o.remove(i4);
                    try {
                        ((y2.k) gVar2).a();
                    } catch (RuntimeException e4) {
                        Log.e("PlatformViewsController2", "Disposing platform view threw an exception", e4);
                    }
                    J2.b bVar2 = (J2.b) pVar.f4656p.get(i4);
                    if (bVar2 != null) {
                        bVar2.removeAllViews();
                        bVar2.a();
                        ViewGroup viewGroup5 = (ViewGroup) bVar2.getParent();
                        if (viewGroup5 != null) {
                            viewGroup5.removeView(bVar2);
                        }
                        pVar.f4656p.remove(i4);
                    }
                } else {
                    S.j("Disposing unknown platform view with id: ", i4, "PlatformViewsController2");
                }
                break;
        }
    }

    @Override // N2.i
    public void q(N2.f fVar) {
        switch (this.f4646a) {
            case 0:
                q qVar = (q) this.f4647b;
                float f4 = qVar.f4668c.getResources().getDisplayMetrics().density;
                int i4 = fVar.f1147a;
                if (!qVar.m(i4)) {
                    g gVar = (g) qVar.f4676r.get(i4);
                    if (gVar == null) {
                        S.j("Sending touch to an unknown view with id: ", i4, "PlatformViewsController");
                    } else {
                        FrameLayout frameLayout = ((y2.k) gVar).f6916c;
                        if (frameLayout == null) {
                            S.j("Sending touch to a null view with id: ", i4, "PlatformViewsController");
                        } else {
                            frameLayout.dispatchTouchEvent(qVar.l(f4, fVar, false));
                        }
                    }
                    break;
                } else {
                    C c5 = (C) qVar.f4674p.get(Integer.valueOf(i4));
                    MotionEvent motionEventL = qVar.l(f4, fVar, true);
                    SingleViewPresentation singleViewPresentation = c5.f4607a;
                    if (singleViewPresentation != null) {
                        singleViewPresentation.dispatchTouchEvent(motionEventL);
                        break;
                    }
                }
                break;
            default:
                p pVar = (p) this.f4647b;
                float f5 = pVar.f4650c.getResources().getDisplayMetrics().density;
                SparseArray sparseArray = pVar.f4655o;
                int i5 = fVar.f1147a;
                g gVar2 = (g) sparseArray.get(i5);
                if (gVar2 == null) {
                    S.j("Sending touch to an unknown view with id: ", i5, "PlatformViewsController2");
                } else {
                    FrameLayout frameLayout2 = ((y2.k) gVar2).f6916c;
                    if (frameLayout2 == null) {
                        S.j("Sending touch to a null view with id: ", i5, "PlatformViewsController2");
                    } else {
                        MotionEvent motionEventA = pVar.f4657q.A(new K(fVar.f1161p));
                        List<List> list = (List) fVar.f1152g;
                        ArrayList arrayList = new ArrayList();
                        for (List list2 : list) {
                            MotionEvent.PointerCoords pointerCoords = new MotionEvent.PointerCoords();
                            pointerCoords.orientation = (float) ((Double) list2.get(0)).doubleValue();
                            pointerCoords.pressure = (float) ((Double) list2.get(1)).doubleValue();
                            pointerCoords.size = (float) ((Double) list2.get(2)).doubleValue();
                            double d5 = f5;
                            pointerCoords.toolMajor = (float) (((Double) list2.get(3)).doubleValue() * d5);
                            pointerCoords.toolMinor = (float) (((Double) list2.get(4)).doubleValue() * d5);
                            pointerCoords.touchMajor = (float) (((Double) list2.get(5)).doubleValue() * d5);
                            pointerCoords.touchMinor = (float) (((Double) list2.get(6)).doubleValue() * d5);
                            pointerCoords.x = (float) (((Double) list2.get(7)).doubleValue() * d5);
                            pointerCoords.y = (float) (((Double) list2.get(8)).doubleValue() * d5);
                            arrayList.add(pointerCoords);
                        }
                        int i6 = fVar.e;
                        MotionEvent.PointerCoords[] pointerCoordsArr = (MotionEvent.PointerCoords[]) arrayList.toArray(new MotionEvent.PointerCoords[i6]);
                        if (motionEventA == null) {
                            List<List> list3 = (List) fVar.f1151f;
                            ArrayList arrayList2 = new ArrayList();
                            for (List list4 : list3) {
                                MotionEvent.PointerProperties pointerProperties = new MotionEvent.PointerProperties();
                                pointerProperties.id = ((Integer) list4.get(0)).intValue();
                                pointerProperties.toolType = ((Integer) list4.get(1)).intValue();
                                arrayList2.add(pointerProperties);
                            }
                            motionEventA = MotionEvent.obtain(fVar.f1148b.longValue(), fVar.f1149c.longValue(), fVar.f1150d, fVar.e, (MotionEvent.PointerProperties[]) arrayList2.toArray(new MotionEvent.PointerProperties[i6]), pointerCoordsArr, fVar.f1153h, fVar.f1154i, fVar.f1155j, fVar.f1156k, fVar.f1157l, fVar.f1158m, fVar.f1159n, fVar.f1160o);
                        } else if (pointerCoordsArr.length >= 1) {
                            motionEventA.offsetLocation(pointerCoordsArr[0].x - motionEventA.getX(), pointerCoordsArr[0].y - motionEventA.getY());
                        }
                        frameLayout2.dispatchTouchEvent(motionEventA);
                    }
                }
                break;
        }
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r3v8, types: [io.flutter.plugin.platform.m, java.lang.Runnable] */
    @Override // N2.i
    public void r(N2.h hVar, final N2.g gVar) {
        h hVar2;
        q qVar = (q) this.f4647b;
        int iN = qVar.n(hVar.f1164b);
        int iN2 = qVar.n(hVar.f1165c);
        int i4 = hVar.f1163a;
        if (!qVar.m(i4)) {
            g gVar2 = (g) qVar.f4676r.get(i4);
            i iVar = (i) qVar.f4679u.get(i4);
            if (gVar2 == null || iVar == null) {
                S.j("Resizing unknown platform view with id: ", i4, "PlatformViewsController");
                return;
            }
            if ((iN > iVar.getRenderTargetWidth() || iN2 > iVar.getRenderTargetHeight()) && (hVar2 = iVar.f4634f) != null) {
                hVar2.d(iN, iN2);
            }
            ViewGroup.LayoutParams layoutParams = iVar.getLayoutParams();
            layoutParams.width = iN;
            layoutParams.height = iN2;
            iVar.setLayoutParams(layoutParams);
            FrameLayout frameLayout = ((y2.k) gVar2).f6916c;
            if (frameLayout != null) {
                ViewGroup.LayoutParams layoutParams2 = frameLayout.getLayoutParams();
                layoutParams2.width = iN;
                layoutParams2.height = iN2;
                frameLayout.setLayoutParams(layoutParams2);
            }
            int iRound = (int) Math.round(((double) iVar.getRenderTargetWidth()) / ((double) qVar.h()));
            int iRound2 = (int) Math.round(((double) iVar.getRenderTargetHeight()) / ((double) qVar.h()));
            N2.j jVar = gVar.f1162a;
            HashMap map = new HashMap();
            map.put("width", Double.valueOf(iRound));
            map.put("height", Double.valueOf(iRound2));
            jVar.c(map);
            return;
        }
        final float fH = qVar.h();
        final C c5 = (C) qVar.f4674p.get(Integer.valueOf(i4));
        io.flutter.plugin.editing.i iVar2 = qVar.f4671m;
        if (iVar2 != null) {
            if (iVar2.e.f55b == 3) {
                iVar2.f4600p = true;
            }
            SingleViewPresentation singleViewPresentation = c5.f4607a;
            if (singleViewPresentation != null && singleViewPresentation.getView() != null) {
                c5.f4607a.getView().getClass();
            }
        }
        ?? r32 = new Runnable() { // from class: io.flutter.plugin.platform.m
            @Override // java.lang.Runnable
            public final void run() {
                q qVar2 = (q) this.f4642a.f4647b;
                io.flutter.plugin.editing.i iVar3 = qVar2.f4671m;
                C c6 = c5;
                if (iVar3 != null) {
                    if (iVar3.e.f55b == 3) {
                        iVar3.f4600p = false;
                    }
                    SingleViewPresentation singleViewPresentation2 = c6.f4607a;
                    if (singleViewPresentation2 != null && singleViewPresentation2.getView() != null) {
                        c6.f4607a.getView().getClass();
                    }
                }
                double dH = qVar2.f4668c == null ? fH : qVar2.h();
                int iRound3 = (int) Math.round(((double) c6.f4611f.getWidth()) / dH);
                int iRound4 = (int) Math.round(((double) c6.f4611f.getHeight()) / dH);
                N2.j jVar2 = gVar.f1162a;
                HashMap map2 = new HashMap();
                map2.put("width", Double.valueOf(iRound3));
                map2.put("height", Double.valueOf(iRound4));
                jVar2.c(map2);
            }
        };
        int width = c5.f4611f.getWidth();
        h hVar3 = c5.f4611f;
        if (iN == width && iN2 == hVar3.getHeight()) {
            c5.a().postDelayed(r32, 0L);
            return;
        }
        if (Build.VERSION.SDK_INT >= 31) {
            FrameLayout frameLayoutA = c5.a();
            hVar3.d(iN, iN2);
            c5.f4613h.resize(iN, iN2, c5.f4610d);
            c5.f4613h.setSurface(hVar3.getSurface());
            frameLayoutA.postDelayed(r32, 0L);
            return;
        }
        boolean zIsFocused = c5.a().isFocused();
        v vVarDetachState = c5.f4607a.detachState();
        c5.f4613h.setSurface(null);
        c5.f4613h.release();
        DisplayManager displayManager = (DisplayManager) c5.f4608b.getSystemService("display");
        hVar3.d(iN, iN2);
        c5.f4613h = displayManager.createVirtualDisplay("flutter-vd#" + c5.e, iN, iN2, c5.f4610d, hVar3.getSurface(), 0, C.f4606i, null);
        FrameLayout frameLayoutA2 = c5.a();
        frameLayoutA2.addOnAttachStateChangeListener(new A(frameLayoutA2, (m) r32));
        SingleViewPresentation singleViewPresentation2 = new SingleViewPresentation(c5.f4608b, c5.f4613h.getDisplay(), c5.f4609c, vVarDetachState, c5.f4612g, zIsFocused);
        singleViewPresentation2.show();
        c5.f4607a.cancel();
        c5.f4607a = singleViewPresentation2;
    }

    @Override // io.flutter.plugin.platform.h
    public void release() {
        ((TextureRegistry$SurfaceProducer) this.f4647b).release();
        this.f4647b = null;
    }

    @Override // io.flutter.plugin.platform.h
    public void scheduleFrame() {
        ((TextureRegistry$SurfaceProducer) this.f4647b).scheduleFrame();
    }

    public n(int i4) {
        this.f4646a = i4;
        switch (i4) {
            case 4:
                break;
            default:
                this.f4647b = new HashMap();
                break;
        }
    }
}
