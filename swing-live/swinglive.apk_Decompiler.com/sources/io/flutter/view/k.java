package io.flutter.view;

import A.T;
import I.C0053n;
import android.R;
import android.content.ContentResolver;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import android.text.SpannableString;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityNodeProvider;
import android.widget.FrameLayout;
import io.flutter.embedding.engine.FlutterJNI;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class k extends AccessibilityNodeProvider {

    /* JADX INFO: renamed from: y, reason: collision with root package name */
    public static final /* synthetic */ int f4787y = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final View f4788a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0747k f4789b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final AccessibilityManager f4790c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final AccessibilityViewEmbedder f4791d;
    public final io.flutter.plugin.platform.j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final ContentResolver f4792f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final HashMap f4793g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final HashMap f4794h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public j f4795i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public Integer f4796j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public Integer f4797k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public int f4798l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public String f4799m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public j f4800n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public j f4801o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public j f4802p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final ArrayList f4803q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public int f4804r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public B.k f4805s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public boolean f4806t;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f4807u;
    public final f v;

    /* JADX INFO: renamed from: w, reason: collision with root package name */
    public final g f4808w;

    /* JADX INFO: renamed from: x, reason: collision with root package name */
    public final D2.o f4809x;

    public k(View view, C0747k c0747k, AccessibilityManager accessibilityManager, ContentResolver contentResolver, io.flutter.plugin.platform.j jVar) {
        AccessibilityViewEmbedder accessibilityViewEmbedder = new AccessibilityViewEmbedder(view, 65536);
        this.f4793g = new HashMap();
        this.f4794h = new HashMap();
        this.f4798l = 0;
        this.f4803q = new ArrayList();
        this.f4804r = 0;
        this.f4806t = false;
        this.f4807u = false;
        e eVar = new e(this);
        f fVar = new f(this);
        this.v = fVar;
        D2.o oVar = new D2.o(this, new Handler(), 2);
        this.f4809x = oVar;
        this.f4788a = view;
        this.f4789b = c0747k;
        this.f4790c = accessibilityManager;
        this.f4792f = contentResolver;
        this.f4791d = accessibilityViewEmbedder;
        this.e = jVar;
        c0747k.f6833d = eVar;
        ((FlutterJNI) c0747k.f6832c).setAccessibilityDelegate(eVar);
        fVar.onAccessibilityStateChanged(accessibilityManager.isEnabled());
        accessibilityManager.addAccessibilityStateChangeListener(fVar);
        g gVar = new g(this, accessibilityManager);
        this.f4808w = gVar;
        gVar.onTouchExplorationStateChanged(accessibilityManager.isTouchExplorationEnabled());
        accessibilityManager.addTouchExplorationStateChangeListener(gVar);
        this.f4798l |= 128;
        oVar.onChange(false, null);
        contentResolver.registerContentObserver(Settings.Global.getUriFor("transition_animation_scale"), false, oVar);
        if (Build.VERSION.SDK_INT >= 31 && view != null && view.getResources() != null) {
            int i4 = view.getResources().getConfiguration().fontWeightAdjustment;
            if (i4 == Integer.MAX_VALUE || i4 < 300) {
                this.f4798l &= -9;
            } else {
                this.f4798l |= 8;
            }
            ((FlutterJNI) c0747k.f6832c).setAccessibilityFeatures(this.f4798l);
        }
        jVar.f(this);
    }

    public static String d(ByteBuffer byteBuffer, String[] strArr) {
        int i4 = byteBuffer.getInt();
        if (i4 == -1) {
            return null;
        }
        return strArr[i4];
    }

    public final boolean a(FrameLayout frameLayout, View view, AccessibilityEvent accessibilityEvent) {
        Integer recordFlutterId;
        AccessibilityViewEmbedder accessibilityViewEmbedder = this.f4791d;
        if (!accessibilityViewEmbedder.requestSendAccessibilityEvent(frameLayout, view, accessibilityEvent) || (recordFlutterId = accessibilityViewEmbedder.getRecordFlutterId(frameLayout, accessibilityEvent)) == null) {
            return false;
        }
        int eventType = accessibilityEvent.getEventType();
        if (eventType == 8) {
            this.f4797k = recordFlutterId;
            this.f4800n = null;
            return true;
        }
        if (eventType == 128) {
            this.f4802p = null;
            return true;
        }
        if (eventType == 32768) {
            this.f4796j = recordFlutterId;
            this.f4795i = null;
            return true;
        }
        if (eventType != 65536) {
            return true;
        }
        this.f4797k = null;
        this.f4796j = null;
        return true;
    }

    public final i b(int i4) {
        HashMap map = this.f4794h;
        i iVar = (i) map.get(Integer.valueOf(i4));
        if (iVar != null) {
            return iVar;
        }
        i iVar2 = new i();
        iVar2.f4733c = -1;
        iVar2.f4732b = i4;
        iVar2.f4731a = 267386881 + i4;
        map.put(Integer.valueOf(i4), iVar2);
        return iVar2;
    }

    public final j c(int i4) {
        HashMap map = this.f4793g;
        j jVar = (j) map.get(Integer.valueOf(i4));
        if (jVar != null) {
            return jVar;
        }
        j jVar2 = new j(this);
        jVar2.f4762b = i4;
        map.put(Integer.valueOf(i4), jVar2);
        return jVar2;
    }

    @Override // android.view.accessibility.AccessibilityNodeProvider
    public final AccessibilityNodeInfo createAccessibilityNodeInfo(int i4) {
        boolean zG;
        String str;
        int i5;
        int i6;
        j(true);
        AccessibilityViewEmbedder accessibilityViewEmbedder = this.f4791d;
        if (i4 >= 65536) {
            return accessibilityViewEmbedder.createAccessibilityNodeInfo(i4);
        }
        HashMap map = this.f4793g;
        View view = this.f4788a;
        if (i4 == -1) {
            AccessibilityNodeInfo accessibilityNodeInfoObtain = AccessibilityNodeInfo.obtain(view);
            view.onInitializeAccessibilityNodeInfo(accessibilityNodeInfoObtain);
            if (map.containsKey(0)) {
                accessibilityNodeInfoObtain.addChild(view, 0);
            }
            accessibilityNodeInfoObtain.setImportantForAccessibility(false);
            return accessibilityNodeInfoObtain;
        }
        j jVar = (j) map.get(Integer.valueOf(i4));
        if (jVar != null) {
            int i7 = jVar.f4770i;
            io.flutter.plugin.platform.j jVar2 = this.e;
            if (i7 == -1 || !jVar2.m(i7)) {
                AccessibilityNodeInfo accessibilityNodeInfoObtain2 = AccessibilityNodeInfo.obtain(view, i4);
                accessibilityNodeInfoObtain2.setImportantForAccessibility((jVar.g(12) || (j.b(jVar) == null && jVar.f4766d == 0)) ? false : true);
                accessibilityNodeInfoObtain2.setViewIdResourceName("");
                String str2 = jVar.f4776o;
                if (str2 != null) {
                    accessibilityNodeInfoObtain2.setViewIdResourceName(str2);
                }
                accessibilityNodeInfoObtain2.setPackageName(view.getContext().getPackageName());
                accessibilityNodeInfoObtain2.setClassName("android.view.View");
                accessibilityNodeInfoObtain2.setSource(view, i4);
                accessibilityNodeInfoObtain2.setFocusable(jVar.i());
                j jVar3 = this.f4800n;
                if (jVar3 != null) {
                    accessibilityNodeInfoObtain2.setFocused(jVar3.f4762b == i4);
                }
                j jVar4 = this.f4795i;
                if (jVar4 != null) {
                    accessibilityNodeInfoObtain2.setAccessibilityFocused(jVar4.f4762b == i4);
                }
                if (jVar.g(5)) {
                    accessibilityNodeInfoObtain2.setPassword(jVar.g(11));
                    if (!jVar.g(21)) {
                        accessibilityNodeInfoObtain2.setClassName("android.widget.EditText");
                    }
                    accessibilityNodeInfoObtain2.setEditable(!jVar.g(21));
                    int i8 = jVar.f4768g;
                    if (i8 != -1 && (i6 = jVar.f4769h) != -1) {
                        accessibilityNodeInfoObtain2.setTextSelection(i8, i6);
                    }
                    j jVar5 = this.f4795i;
                    if (jVar5 != null && jVar5.f4762b == i4) {
                        accessibilityNodeInfoObtain2.setLiveRegion(1);
                    }
                    if (j.a(jVar, h.MOVE_CURSOR_FORWARD_BY_CHARACTER)) {
                        accessibilityNodeInfoObtain2.addAction(256);
                        i5 = 1;
                    } else {
                        i5 = 0;
                    }
                    if (j.a(jVar, h.MOVE_CURSOR_BACKWARD_BY_CHARACTER)) {
                        accessibilityNodeInfoObtain2.addAction(512);
                        i5 = 1;
                    }
                    if (j.a(jVar, h.MOVE_CURSOR_FORWARD_BY_WORD)) {
                        accessibilityNodeInfoObtain2.addAction(256);
                        i5 |= 2;
                    }
                    if (j.a(jVar, h.MOVE_CURSOR_BACKWARD_BY_WORD)) {
                        accessibilityNodeInfoObtain2.addAction(512);
                        i5 |= 2;
                    }
                    accessibilityNodeInfoObtain2.setMovementGranularities(i5);
                    if (jVar.e >= 0) {
                        String str3 = jVar.f4779r;
                        accessibilityNodeInfoObtain2.setMaxTextLength(((str3 == null ? 0 : str3.length()) - jVar.f4767f) + jVar.e);
                    }
                }
                if (j.a(jVar, h.SET_SELECTION)) {
                    accessibilityNodeInfoObtain2.addAction(131072);
                }
                if (j.a(jVar, h.COPY)) {
                    accessibilityNodeInfoObtain2.addAction(16384);
                }
                if (j.a(jVar, h.CUT)) {
                    accessibilityNodeInfoObtain2.addAction(65536);
                }
                if (j.a(jVar, h.PASTE)) {
                    accessibilityNodeInfoObtain2.addAction(32768);
                }
                if (j.a(jVar, h.SET_TEXT)) {
                    accessibilityNodeInfoObtain2.addAction(2097152);
                }
                if (jVar.g(4)) {
                    zG = true;
                } else {
                    String str4 = jVar.f4735A;
                    zG = (str4 == null || str4.isEmpty()) ? jVar.g(23) : false;
                }
                if (zG) {
                    accessibilityNodeInfoObtain2.setClassName("android.widget.Button");
                }
                if (jVar.g(15)) {
                    accessibilityNodeInfoObtain2.setClassName("android.widget.ImageView");
                }
                if (j.a(jVar, h.DISMISS)) {
                    accessibilityNodeInfoObtain2.setDismissable(true);
                    accessibilityNodeInfoObtain2.addAction(1048576);
                }
                j jVar6 = jVar.f4752S;
                if (jVar6 != null) {
                    accessibilityNodeInfoObtain2.setParent(view, jVar6.f4762b);
                } else {
                    accessibilityNodeInfoObtain2.setParent(view);
                }
                int i9 = jVar.f4738D;
                if (i9 != -1) {
                    accessibilityNodeInfoObtain2.setTraversalAfter(view, i9);
                }
                Rect rect = jVar.f4765c0;
                j jVar7 = jVar.f4752S;
                if (jVar7 != null) {
                    Rect rect2 = jVar7.f4765c0;
                    Rect rect3 = new Rect(rect);
                    rect3.offset(-rect2.left, -rect2.top);
                    accessibilityNodeInfoObtain2.setBoundsInParent(rect3);
                } else {
                    accessibilityNodeInfoObtain2.setBoundsInParent(rect);
                }
                Rect rect4 = new Rect(rect);
                int[] iArr = new int[2];
                view.getLocationOnScreen(iArr);
                rect4.offset(iArr[0], iArr[1]);
                accessibilityNodeInfoObtain2.setBoundsInScreen(rect4);
                accessibilityNodeInfoObtain2.setVisibleToUser(true);
                accessibilityNodeInfoObtain2.setEnabled(!jVar.g(7) || jVar.g(8));
                if (j.a(jVar, h.TAP)) {
                    if (jVar.f4756W != null) {
                        accessibilityNodeInfoObtain2.addAction(new AccessibilityNodeInfo.AccessibilityAction(16, jVar.f4756W.e));
                        accessibilityNodeInfoObtain2.setClickable(true);
                    } else {
                        accessibilityNodeInfoObtain2.addAction(16);
                        accessibilityNodeInfoObtain2.setClickable(true);
                    }
                } else if (jVar.g(24)) {
                    accessibilityNodeInfoObtain2.addAction(16);
                    accessibilityNodeInfoObtain2.setClickable(true);
                }
                if (j.a(jVar, h.LONG_PRESS)) {
                    if (jVar.f4757X != null) {
                        accessibilityNodeInfoObtain2.addAction(new AccessibilityNodeInfo.AccessibilityAction(32, jVar.f4757X.e));
                        accessibilityNodeInfoObtain2.setLongClickable(true);
                    } else {
                        accessibilityNodeInfoObtain2.addAction(32);
                        accessibilityNodeInfoObtain2.setLongClickable(true);
                    }
                }
                h hVar = h.SCROLL_LEFT;
                boolean zA = j.a(jVar, hVar);
                h hVar2 = h.SCROLL_DOWN;
                h hVar3 = h.SCROLL_UP;
                h hVar4 = h.SCROLL_RIGHT;
                if (zA || j.a(jVar, hVar3) || j.a(jVar, hVar4) || j.a(jVar, hVar2)) {
                    accessibilityNodeInfoObtain2.setScrollable(true);
                    if (jVar.g(19)) {
                        if (j.a(jVar, hVar) || j.a(jVar, hVar4)) {
                            accessibilityNodeInfoObtain2.setClassName("android.widget.HorizontalScrollView");
                        } else {
                            accessibilityNodeInfoObtain2.setClassName("android.widget.ScrollView");
                        }
                    }
                }
                if (k(jVar)) {
                    if (j.a(jVar, hVar) || j.a(jVar, hVar4)) {
                        if (Build.VERSION.SDK_INT < 33) {
                            accessibilityNodeInfoObtain2.setCollectionInfo(AccessibilityNodeInfo.CollectionInfo.obtain(1, jVar.f4771j, false));
                        } else {
                            accessibilityNodeInfoObtain2.setCollectionInfo(c.d(jVar.f4771j));
                        }
                    } else if (Build.VERSION.SDK_INT < 33) {
                        accessibilityNodeInfoObtain2.setCollectionInfo(AccessibilityNodeInfo.CollectionInfo.obtain(jVar.f4771j, 1, false));
                    } else {
                        accessibilityNodeInfoObtain2.setCollectionInfo(T.l(jVar.f4771j));
                    }
                }
                j jVar8 = jVar.f4752S;
                if (jVar8 != null && k(jVar8) && jVar.f4752S.g(19)) {
                    j jVar9 = jVar.f4752S;
                    ArrayList arrayList = jVar9.f4753T;
                    boolean z4 = (j.a(jVar9, hVar) || j.a(jVar9, hVar4)) ? false : true;
                    int iIndexOf = arrayList.indexOf(jVar);
                    if (z4) {
                        if (Build.VERSION.SDK_INT < 33) {
                            accessibilityNodeInfoObtain2.setCollectionItemInfo(AccessibilityNodeInfo.CollectionItemInfo.obtain(iIndexOf, 1, 0, 1, jVar.g(10)));
                        } else {
                            accessibilityNodeInfoObtain2.setCollectionItemInfo(c.e(iIndexOf, jVar.g(10)));
                        }
                    } else if (Build.VERSION.SDK_INT < 33) {
                        accessibilityNodeInfoObtain2.setCollectionItemInfo(AccessibilityNodeInfo.CollectionItemInfo.obtain(0, 1, iIndexOf, 1, jVar.g(10)));
                    } else {
                        accessibilityNodeInfoObtain2.setCollectionItemInfo(c.h(iIndexOf, jVar.g(10)));
                    }
                }
                if (j.a(jVar, hVar) || j.a(jVar, hVar3)) {
                    accessibilityNodeInfoObtain2.addAction(4096);
                }
                if (j.a(jVar, hVar4) || j.a(jVar, hVar2)) {
                    accessibilityNodeInfoObtain2.addAction(8192);
                }
                h hVar5 = h.INCREASE;
                boolean zA2 = j.a(jVar, hVar5);
                h hVar6 = h.DECREASE;
                if (zA2 || j.a(jVar, hVar6)) {
                    accessibilityNodeInfoObtain2.setClassName("android.widget.SeekBar");
                    if (j.a(jVar, hVar5)) {
                        accessibilityNodeInfoObtain2.addAction(4096);
                    }
                    if (j.a(jVar, hVar6)) {
                        accessibilityNodeInfoObtain2.addAction(8192);
                    }
                }
                if (jVar.g(16)) {
                    accessibilityNodeInfoObtain2.setLiveRegion(1);
                }
                if (jVar.g(5)) {
                    C0053n c0053n = new C0053n(10, false);
                    c0053n.f706b = jVar.f4779r;
                    c0053n.f707c = jVar.f4780s;
                    c0053n.f708d = jVar.d();
                    accessibilityNodeInfoObtain2.setText(c0053n.e());
                    if (Build.VERSION.SDK_INT >= 28) {
                        C0053n c0053n2 = new C0053n(10, false);
                        c0053n2.f706b = jVar.f4777p;
                        c0053n2.f707c = jVar.f4778q;
                        c0053n2.e = jVar.f4735A;
                        c0053n2.f708d = jVar.d();
                        SpannableString spannableStringE = c0053n2.e();
                        C0053n c0053n3 = new C0053n(10, false);
                        c0053n3.f706b = jVar.f4784x;
                        c0053n3.f707c = jVar.f4785y;
                        c0053n3.f708d = jVar.d();
                        CharSequence[] charSequenceArr = {spannableStringE, c0053n3.e()};
                        int i10 = 0;
                        CharSequence charSequence = null;
                        for (int i11 = 2; i10 < i11; i11 = 2) {
                            CharSequence charSequenceConcat = charSequenceArr[i10];
                            if (charSequenceConcat != null && charSequenceConcat.length() > 0) {
                                if (charSequence != null && charSequence.length() != 0) {
                                    charSequenceConcat = TextUtils.concat(charSequence, ", ", charSequenceConcat);
                                }
                                charSequence = charSequenceConcat;
                            }
                            i10++;
                        }
                        accessibilityNodeInfoObtain2.setHintText(charSequence);
                    }
                } else if (!jVar.g(12)) {
                    CharSequence charSequenceB = j.b(jVar);
                    if (Build.VERSION.SDK_INT < 28 && jVar.f4786z != null) {
                        charSequenceB = ((Object) (charSequenceB != null ? charSequenceB : "")) + "\n" + jVar.f4786z;
                    }
                    if (charSequenceB != null) {
                        accessibilityNodeInfoObtain2.setContentDescription(charSequenceB);
                    }
                }
                int i12 = Build.VERSION.SDK_INT;
                if (i12 >= 28 && (str = jVar.f4786z) != null) {
                    accessibilityNodeInfoObtain2.setTooltipText(str);
                    if (j.b(jVar) == null) {
                        accessibilityNodeInfoObtain2.setContentDescription(jVar.f4786z);
                    }
                }
                boolean zG2 = jVar.g(1);
                boolean zG3 = jVar.g(17);
                accessibilityNodeInfoObtain2.setCheckable(zG2 || zG3);
                if (zG2) {
                    accessibilityNodeInfoObtain2.setChecked(jVar.g(2));
                    if (jVar.g(9)) {
                        accessibilityNodeInfoObtain2.setClassName("android.widget.RadioButton");
                    } else {
                        accessibilityNodeInfoObtain2.setClassName("android.widget.CheckBox");
                    }
                } else if (zG3) {
                    accessibilityNodeInfoObtain2.setChecked(jVar.g(18));
                    accessibilityNodeInfoObtain2.setClassName("android.widget.Switch");
                }
                accessibilityNodeInfoObtain2.setSelected(jVar.g(3));
                if (i12 >= 36 && jVar.g(27)) {
                    accessibilityNodeInfoObtain2.setExpandedState(jVar.g(28) ? 3 : 1);
                    if (j.a(jVar, h.EXPAND)) {
                        accessibilityNodeInfoObtain2.addAction(262144);
                    }
                    if (j.a(jVar, h.COLLAPSE)) {
                        accessibilityNodeInfoObtain2.addAction(524288);
                    }
                }
                if (i12 >= 28) {
                    accessibilityNodeInfoObtain2.setHeading(jVar.f4737C > 0);
                }
                j jVar10 = this.f4795i;
                if (jVar10 == null || jVar10.f4762b != i4) {
                    accessibilityNodeInfoObtain2.addAction(64);
                } else {
                    accessibilityNodeInfoObtain2.addAction(128);
                }
                ArrayList<i> arrayList2 = jVar.f4755V;
                if (arrayList2 != null) {
                    for (i iVar : arrayList2) {
                        accessibilityNodeInfoObtain2.addAction(new AccessibilityNodeInfo.AccessibilityAction(iVar.f4731a, iVar.f4734d));
                    }
                }
                for (j jVar11 : jVar.f4753T) {
                    if (!jVar11.g(14)) {
                        int i13 = jVar11.f4770i;
                        if (i13 != -1) {
                            FrameLayout frameLayoutS = jVar2.s(i13);
                            if (!jVar2.m(jVar11.f4770i) && frameLayoutS != null) {
                                frameLayoutS.setImportantForAccessibility(0);
                                accessibilityNodeInfoObtain2.addChild(frameLayoutS);
                            }
                        }
                        accessibilityNodeInfoObtain2.addChild(view, jVar11.f4762b);
                    }
                }
                return accessibilityNodeInfoObtain2;
            }
            FrameLayout frameLayoutS2 = jVar2.s(jVar.f4770i);
            if (frameLayoutS2 != null) {
                return accessibilityViewEmbedder.getRootNode(frameLayoutS2, jVar.f4762b, jVar.f4765c0);
            }
        }
        return null;
    }

    public final AccessibilityEvent e(int i4, int i5) {
        AccessibilityEvent accessibilityEventObtain = AccessibilityEvent.obtain(i5);
        View view = this.f4788a;
        accessibilityEventObtain.setPackageName(view.getContext().getPackageName());
        accessibilityEventObtain.setSource(view, i4);
        return accessibilityEventObtain;
    }

    public final boolean f(MotionEvent motionEvent, boolean z4) {
        j jVarH;
        if (this.f4790c.isTouchExplorationEnabled()) {
            HashMap map = this.f4793g;
            if (!map.isEmpty()) {
                j jVarH2 = ((j) map.get(0)).h(new float[]{motionEvent.getX(), motionEvent.getY(), 0.0f, 1.0f}, z4);
                if (jVarH2 == null || jVarH2.f4770i == -1) {
                    if (motionEvent.getAction() == 9 || motionEvent.getAction() == 7) {
                        float x4 = motionEvent.getX();
                        float y4 = motionEvent.getY();
                        if (!map.isEmpty() && (jVarH = ((j) map.get(0)).h(new float[]{x4, y4, 0.0f, 1.0f}, z4)) != this.f4802p) {
                            if (jVarH != null) {
                                h(jVarH.f4762b, 128);
                            }
                            j jVar = this.f4802p;
                            if (jVar != null) {
                                h(jVar.f4762b, 256);
                            }
                            this.f4802p = jVarH;
                        }
                    } else {
                        if (motionEvent.getAction() != 10) {
                            motionEvent.toString();
                            return false;
                        }
                        j jVar2 = this.f4802p;
                        if (jVar2 != null) {
                            h(jVar2.f4762b, 256);
                            this.f4802p = null;
                        }
                    }
                    return true;
                }
                if (!z4) {
                    return this.f4791d.onAccessibilityHoverEvent(jVarH2.f4762b, motionEvent);
                }
            }
        }
        return false;
    }

    @Override // android.view.accessibility.AccessibilityNodeProvider
    public final AccessibilityNodeInfo findFocus(int i4) {
        if (i4 == 1) {
            j jVar = this.f4800n;
            if (jVar != null) {
                return createAccessibilityNodeInfo(jVar.f4762b);
            }
            Integer num = this.f4797k;
            if (num != null) {
                return createAccessibilityNodeInfo(num.intValue());
            }
        } else if (i4 != 2) {
            return null;
        }
        j jVar2 = this.f4795i;
        if (jVar2 != null) {
            return createAccessibilityNodeInfo(jVar2.f4762b);
        }
        Integer num2 = this.f4796j;
        if (num2 != null) {
            return createAccessibilityNodeInfo(num2.intValue());
        }
        return null;
    }

    public final boolean g(j jVar, int i4, Bundle bundle, boolean z4) {
        int i5;
        int i6 = bundle.getInt("ACTION_ARGUMENT_MOVEMENT_GRANULARITY_INT");
        boolean z5 = bundle.getBoolean("ACTION_ARGUMENT_EXTEND_SELECTION_BOOLEAN");
        int i7 = jVar.f4768g;
        int i8 = jVar.f4769h;
        if (i8 >= 0 && i7 >= 0) {
            if (i6 != 1) {
                if (i6 != 2) {
                    if (i6 != 4) {
                        if (i6 == 8 || i6 == 16) {
                            if (z4) {
                                jVar.f4769h = jVar.f4779r.length();
                            } else {
                                jVar.f4769h = 0;
                            }
                        }
                    } else if (z4 && i8 < jVar.f4779r.length()) {
                        Matcher matcher = Pattern.compile("(?!^)(\\n)").matcher(jVar.f4779r.substring(jVar.f4769h));
                        if (matcher.find()) {
                            jVar.f4769h += matcher.start(1);
                        } else {
                            jVar.f4769h = jVar.f4779r.length();
                        }
                    } else if (!z4 && jVar.f4769h > 0) {
                        Matcher matcher2 = Pattern.compile("(?s:.*)(\\n)").matcher(jVar.f4779r.substring(0, jVar.f4769h));
                        if (matcher2.find()) {
                            jVar.f4769h = matcher2.start(1);
                        } else {
                            jVar.f4769h = 0;
                        }
                    }
                } else if (z4 && i8 < jVar.f4779r.length()) {
                    Matcher matcher3 = Pattern.compile("\\p{L}(\\b)").matcher(jVar.f4779r.substring(jVar.f4769h));
                    matcher3.find();
                    if (matcher3.find()) {
                        jVar.f4769h += matcher3.start(1);
                    } else {
                        jVar.f4769h = jVar.f4779r.length();
                    }
                } else if (!z4 && jVar.f4769h > 0) {
                    Matcher matcher4 = Pattern.compile("(?s:.*)(\\b)\\p{L}").matcher(jVar.f4779r.substring(0, jVar.f4769h));
                    if (matcher4.find()) {
                        jVar.f4769h = matcher4.start(1);
                    }
                }
            } else if (z4 && i8 < jVar.f4779r.length()) {
                jVar.f4769h++;
            } else if (!z4 && (i5 = jVar.f4769h) > 0) {
                jVar.f4769h = i5 - 1;
            }
            if (!z5) {
                jVar.f4768g = jVar.f4769h;
            }
        }
        if (i7 != jVar.f4768g || i8 != jVar.f4769h) {
            String str = jVar.f4779r;
            if (str == null) {
                str = "";
            }
            AccessibilityEvent accessibilityEventE = e(jVar.f4762b, 8192);
            accessibilityEventE.getText().add(str);
            accessibilityEventE.setFromIndex(jVar.f4768g);
            accessibilityEventE.setToIndex(jVar.f4769h);
            accessibilityEventE.setItemCount(str.length());
            i(accessibilityEventE);
        }
        C0747k c0747k = this.f4789b;
        if (i6 == 1) {
            if (z4) {
                h hVar = h.MOVE_CURSOR_FORWARD_BY_CHARACTER;
                if (j.a(jVar, hVar)) {
                    c0747k.A(i4, hVar, Boolean.valueOf(z5));
                    return true;
                }
            }
            if (!z4) {
                h hVar2 = h.MOVE_CURSOR_BACKWARD_BY_CHARACTER;
                if (j.a(jVar, hVar2)) {
                    c0747k.A(i4, hVar2, Boolean.valueOf(z5));
                    return true;
                }
            }
        } else if (i6 == 2) {
            if (z4) {
                h hVar3 = h.MOVE_CURSOR_FORWARD_BY_WORD;
                if (j.a(jVar, hVar3)) {
                    c0747k.A(i4, hVar3, Boolean.valueOf(z5));
                    return true;
                }
            }
            if (!z4) {
                h hVar4 = h.MOVE_CURSOR_BACKWARD_BY_WORD;
                if (j.a(jVar, hVar4)) {
                    c0747k.A(i4, hVar4, Boolean.valueOf(z5));
                    return true;
                }
            }
        } else if (i6 == 4 || i6 == 8 || i6 == 16) {
            return true;
        }
        return false;
    }

    public final void h(int i4, int i5) {
        if (this.f4790c.isEnabled()) {
            i(e(i4, i5));
        }
    }

    public final void i(AccessibilityEvent accessibilityEvent) {
        if (this.f4790c.isEnabled()) {
            View view = this.f4788a;
            view.getParent().requestSendAccessibilityEvent(view, accessibilityEvent);
        }
    }

    public final void j(boolean z4) {
        if (this.f4806t == z4) {
            return;
        }
        this.f4806t = z4;
        if (z4) {
            this.f4798l |= 1;
        } else {
            this.f4798l &= -2;
        }
        ((FlutterJNI) this.f4789b.f6832c).setAccessibilityFeatures(this.f4798l);
    }

    public final boolean k(j jVar) {
        if (jVar.f4771j > 1) {
            j jVar2 = this.f4795i;
            j jVar3 = null;
            if (jVar2 != null) {
                j jVar4 = jVar2.f4752S;
                while (true) {
                    if (jVar4 == null) {
                        jVar4 = null;
                        break;
                    }
                    if (jVar4 == jVar) {
                        break;
                    }
                    jVar4 = jVar4.f4752S;
                }
                if (jVar4 != null) {
                    return true;
                }
            }
            j jVar5 = this.f4795i;
            d dVar = new d();
            if (jVar5 != null) {
                j jVar6 = jVar5.f4752S;
                while (true) {
                    if (jVar6 == null) {
                        break;
                    }
                    if (dVar.test(jVar6)) {
                        jVar3 = jVar6;
                        break;
                    }
                    jVar6 = jVar6.f4752S;
                }
                if (jVar3 != null) {
                }
            }
            return true;
        }
        return false;
    }

    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$PrimitiveArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    @Override // android.view.accessibility.AccessibilityNodeProvider
    public final boolean performAction(int i4, int i5, Bundle bundle) {
        if (i4 >= 65536) {
            boolean zPerformAction = this.f4791d.performAction(i4, i5, bundle);
            if (zPerformAction && i5 == 128) {
                this.f4796j = null;
            }
            return zPerformAction;
        }
        HashMap map = this.f4793g;
        j jVar = (j) map.get(Integer.valueOf(i4));
        if (jVar != null) {
            h hVar = h.INCREASE;
            h hVar2 = h.DECREASE;
            C0747k c0747k = this.f4789b;
            switch (i5) {
                case 16:
                    c0747k.z(i4, h.TAP);
                    return true;
                case 32:
                    c0747k.z(i4, h.LONG_PRESS);
                    return true;
                case 64:
                    if (this.f4795i == null) {
                        this.f4788a.invalidate();
                    }
                    this.f4795i = jVar;
                    c0747k.z(i4, h.DID_GAIN_ACCESSIBILITY_FOCUS);
                    HashMap map2 = new HashMap();
                    map2.put("type", "didGainFocus");
                    map2.put("nodeId", Integer.valueOf(jVar.f4762b));
                    ((C0053n) c0747k.f6831b).x(map2, null);
                    h(i4, 32768);
                    if (!j.a(jVar, hVar) && !j.a(jVar, hVar2)) {
                        return true;
                    }
                    h(i4, 4);
                    return true;
                case 128:
                    j jVar2 = this.f4795i;
                    if (jVar2 != null && jVar2.f4762b == i4) {
                        this.f4795i = null;
                    }
                    Integer num = this.f4796j;
                    if (num != null && num.intValue() == i4) {
                        this.f4796j = null;
                    }
                    c0747k.z(i4, h.DID_LOSE_ACCESSIBILITY_FOCUS);
                    h(i4, 65536);
                    return true;
                case 256:
                    return g(jVar, i4, bundle, true);
                case 512:
                    return g(jVar, i4, bundle, false);
                case 4096:
                    h hVar3 = h.SCROLL_UP;
                    if (j.a(jVar, hVar3)) {
                        c0747k.z(i4, hVar3);
                        return true;
                    }
                    h hVar4 = h.SCROLL_LEFT;
                    if (j.a(jVar, hVar4)) {
                        c0747k.z(i4, hVar4);
                        return true;
                    }
                    if (j.a(jVar, hVar)) {
                        jVar.f4779r = jVar.f4781t;
                        jVar.f4780s = jVar.f4782u;
                        h(i4, 4);
                        c0747k.z(i4, hVar);
                        return true;
                    }
                    break;
                case 8192:
                    h hVar5 = h.SCROLL_DOWN;
                    if (j.a(jVar, hVar5)) {
                        c0747k.z(i4, hVar5);
                        return true;
                    }
                    h hVar6 = h.SCROLL_RIGHT;
                    if (j.a(jVar, hVar6)) {
                        c0747k.z(i4, hVar6);
                        return true;
                    }
                    if (j.a(jVar, hVar2)) {
                        jVar.f4779r = jVar.v;
                        jVar.f4780s = jVar.f4783w;
                        h(i4, 4);
                        c0747k.z(i4, hVar2);
                        return true;
                    }
                    break;
                case 16384:
                    c0747k.z(i4, h.COPY);
                    return true;
                case 32768:
                    c0747k.z(i4, h.PASTE);
                    return true;
                case 65536:
                    c0747k.z(i4, h.CUT);
                    return true;
                case 131072:
                    HashMap map3 = new HashMap();
                    if (bundle != null && bundle.containsKey("ACTION_ARGUMENT_SELECTION_START_INT") && bundle.containsKey("ACTION_ARGUMENT_SELECTION_END_INT")) {
                        map3.put("base", Integer.valueOf(bundle.getInt("ACTION_ARGUMENT_SELECTION_START_INT")));
                        map3.put("extent", Integer.valueOf(bundle.getInt("ACTION_ARGUMENT_SELECTION_END_INT")));
                    } else {
                        map3.put("base", Integer.valueOf(jVar.f4769h));
                        map3.put("extent", Integer.valueOf(jVar.f4769h));
                    }
                    c0747k.A(i4, h.SET_SELECTION, map3);
                    j jVar3 = (j) map.get(Integer.valueOf(i4));
                    jVar3.f4768g = ((Integer) map3.get("base")).intValue();
                    jVar3.f4769h = ((Integer) map3.get("extent")).intValue();
                    return true;
                case 262144:
                    c0747k.z(i4, h.EXPAND);
                    return true;
                case 524288:
                    c0747k.z(i4, h.COLLAPSE);
                    return true;
                case 1048576:
                    c0747k.z(i4, h.DISMISS);
                    return true;
                case 2097152:
                    String string = (bundle == null || !bundle.containsKey("ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE")) ? "" : bundle.getString("ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE");
                    c0747k.A(i4, h.SET_TEXT, string);
                    jVar.f4779r = string;
                    jVar.f4780s = null;
                    return true;
                case R.id.accessibilityActionShowOnScreen:
                    c0747k.z(i4, h.SHOW_ON_SCREEN);
                    return true;
                default:
                    i iVar = (i) this.f4794h.get(Integer.valueOf(i5 - 267386881));
                    if (iVar != null) {
                        c0747k.A(i4, h.CUSTOM_ACTION, Integer.valueOf(iVar.f4732b));
                        return true;
                    }
                    break;
            }
        }
        return false;
    }
}
